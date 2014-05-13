require "sensu/settings/validator"

module Sensu
  module Settings
    class Loader
      # @!attribute [r] warnings
      #   @return [Array] loader warnings.
      attr_reader :warnings

      def initialize
        @warnings = []
        @settings = {}
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
