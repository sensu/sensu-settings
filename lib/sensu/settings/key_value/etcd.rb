require 'etcd'
require 'sensu/settings/key_value'

module Sensu
  module Settings
    module KeyValue
      class Etcd
        attr_accessor :url, :chroot, :auth

        def initialize(url, chroot='', auth=nil)
          @url = URI(url)
          @chroot = chroot
          @client = ::Etcd.client(host: @url.host,
                                  port: @url.port,
                                  use_ssl: @url.scheme == 'https' ? true : false
                                 )
        end

        def unpack(node, path, result={})
          if node.dir
            if node.children.empty?
              node = @client.get(node.key).node
            end
            node.children.each do |c_node|
              result = unpack(c_node, path, result)
            end
          else
            key_parts = node.key.split('/')
            sub_result = key_parts.reverse.reduce(node.value) { |r, e| { "#{e}" => r } }
            merger = proc { |k, v1, v2| Hash === v1 && Hash === v2 ? v1.merge(v2, &merger) : v2 }
            result = result.merge(sub_result, &merger)
          end
          result
        end

        def read(path=nil)
          path = "#{@chroot}/#{path}"
          begin
            resp = @client.get(path)
            if resp.node.dir
              Sensu::Settings::KeyValue.deserialize(unpack(resp.node, path))
            else
              Sensu::Settings::KeyValue.deserialize(resp.node.value)
            end
          rescue Etcd::KeyNotFound => e
            raise(Sensu::Settings::KeyValueError, "The #{path} key was not found.")
          end
        end
      end
    end
  end
end
