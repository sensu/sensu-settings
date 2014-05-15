require "sensu/settings/validator"

module Sensu
  module Settings
    class Loader
      # @!attribute [r] warnings
      #   @return [Array] loader warnings.
      attr_reader :warnings

      def initialize
        @warnings = []
        @settings = {
          :checks => {},
          :filters => {},
          :mutators => {},
          :handlers => {}
        }
        @indifferent_access = false
      end

      # Access settings as an indifferent hash.
      #
      # @return [Hash] settings.
      def to_hash
        unless @indifferent_access
          indifferent_access!
        end
        @settings
      end

      # Retrieve the value object corresponding to a key, acting like
      # a Hash object.
      #
      # @param key [Object]
      # @return [Object] value for key.
      def [](key)
        to_hash[key]
      end

      # Load settings from the environment.
      # Loads: RABBITMQ_URL, REDIS_URL, REDISTOGO_URL, API_PORT, PORT
      def load_env
        if ENV["RABBITMQ_URL"]
          @settings[:rabbitmq] = ENV["RABBITMQ_URL"]
          warning(@settings[:rabbitmq], "using rabbitmq url environment variable")
        end
        ENV["REDIS_URL"] ||= ENV["REDISTOGO_URL"]
        if ENV["REDIS_URL"]
          @settings[:redis] = ENV["REDIS_URL"]
          warning(@settings[:redis], "using redis url environment variable")
        end
        ENV["API_PORT"] ||= ENV["PORT"]
        if ENV["API_PORT"]
          @settings[:api] ||= {}
          @settings[:api][:port] = ENV["API_PORT"].to_i
          warning(@settings[:api], "using api port environment variable")
        end
        @indifferent_access = false
      end

      # Load settings from the environment and the paths provided.
      #
      # @param options [Hash]
      # @return [Hash] loaded settings.
      def load(options={})
        load_env
        @settings
      end

      # Validate the loaded settings.
      #
      # @return [Array] validation failures.
      def validate!
        service = ::File.basename($0).split("-").last
        validator = Validator.new
        validator.run(@settings, service)
      end

      private

      # Creates an indifferent hash.
      #
      # @return [Hash] indifferent hash.
      def indifferent_hash
        Hash.new do |hash, key|
          if key.is_a?(String)
            hash[key.to_sym]
          end
        end
      end

      # Create a copy of a hash with indifferent access.
      #
      # @param hash [Hash] hash to make indifferent.
      # @return [Hash] indifferent version of hash.
      def with_indifferent_access(hash)
        hash = indifferent_hash.merge(hash)
        hash.each do |key, value|
          if value.is_a?(Hash)
            hash[key] = with_indifferent_access(value)
          end
        end
      end

      # Update settings to have indifferent access.
      def indifferent_access!
        @settings = with_indifferent_access(@settings)
        @indifferent_access = true
      end

      # Record a warning for an object.
      #
      # @param object [Object]
      # @param message [String] warning message.
      # @return [Array] current warnings.
      def warning(object, message)
        @warnings << {
          :object => object,
          :message => message
        }
      end
    end
  end
end
