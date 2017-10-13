require 'diplomat'
require 'sensu/settings/key_value'

module Sensu
  module Settings
    module KeyValue
      class Consul
        attr_accessor :url, :chroot, :token

        def initialize(url, chroot='', token=nil)
          @url = URI(url)
          @chroot = chroot
          @token = token
          @options = @url.scheme == 'https' ? { ssl: { version: :TLSv1_2, verify: true } } : {}
          configure_diplomat
        end

        def configure_diplomat
          begin
            Diplomat.configure do |diplomat|
              diplomat.url = "#{@url.scheme}://#{@url.host}:#{@url.port}"
              diplomat.acl_token = @token
              diplomat.options = @options
            end
          rescue => e
            raise Sensu::Settings::KeyValueConfigError.new(e.message)
          end
        end

        def read(path)
          path = "#{@chroot}/#{path}"
          recurse = path[-1] == '/'
          begin
            resp = Diplomat.get(path, recurse: recurse)
            if resp.class == Array
              result = {}
              response.each do |key_value|
                key = key_value[:key].gsub(Regexp.new(path), '')
                value = key_value[:value]
                key_parts = key.split('/')

                # deep merge any resulting response
                sub_result = key_parts.reverse.reduce(value) { |r, e| { "#{e}" => r } }
                merger = proc { |k, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
                result = result.merge(sub_result, &merger)
              end
              Sensu::Settings::KeyValue.deserialize(result)
            else
              Sensu::Settings::KeyValue.deserialize(resp)
            end
          rescue Diplomat::KeyNotFound, Diplomat::Unknownstatus => e
            raise(Sensu::Settings::KeyValueError, "The #{path} key was not found. Verify key path and authentication.")
          end
        end
      end
    end
  end
end
