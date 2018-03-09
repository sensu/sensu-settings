require 'sensu/settings/key_value/consul'
require 'sensu/settings/key_value/etcd'
require 'sensu/settings/loader'

module Sensu
  module Settings
    module KeyValue
      class KeyValueError < Exception; end

      class KeyValueConfigError < Exception; end

      class KeyValueTypeUnknown < NameError; end

      class << self
        attr_accessor :errors
        attr_accessor :type, :url, :chroot, :auth

        def deserialize(content)
          case content
          when String
            return Sensu::JSON.load(content)
          when Hash
            result = {}
            content.each do |k,v|
              result[k] = deserialize(v)
            end
            result
          end
        end

        def load_type
          begin
            Sensu::Settings::KeyValue.const_get(type.capitalize).new(@url, @chroot, @auth)
          rescue NameError
            raise(KeyValueTypeUnknown, "Unsupported key-value type: #{type.capitalize}")
          end
        end

        def read!(path=nil)
          load_type.read(path)
        end

        def read(path=nil)
          begin
            read!(path)
          rescue
            nil
          end
        end
      end
    end
  end
end
