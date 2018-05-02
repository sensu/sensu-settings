require "sensu/settings/rules"
require "sensu/settings/validators"
require "sensu/settings/constants"

module Sensu
  module Settings
    class Validator
      include Rules
      include Validators

      # @!attribute [r] failures
      #   @return [Array] validation failures.
      attr_reader :failures

      def initialize
        @failures = []
      end

      # Run the validator.
      #
      # @param settings [Hash] sensu settings to validate.
      # @param service [String] sensu service to validate for.
      # @return [Array] validation failures.
      def run(settings, service=nil)
        validate_sensu(settings[:sensu])
        validate_transport(settings[:transport])
        validate_categories(settings)
        case service
        when "server"
          validate_tessen(settings[:tessen])
        when "client"
          validate_client(settings[:client])
        when "api"
          validate_api(settings[:api])
        when "rspec"
          validate_client(settings[:client])
          validate_api(settings[:api])
        end
        @failures
      end

      def reset!
        failure_count = @failures.size
        @failures = []
        failure_count
      end
      alias_method :reset, :reset!

      private

      # Validate setting categories: checks, filters, mutators, and
      # handlers. This method also validates each object type,
      # ensuring that they are hashes.
      #
      # @param settings [Hash] sensu settings to validate.
      def validate_categories(settings)
        CATEGORIES.each do |category|
          if is_a_hash?(settings[category])
            validate_method = ("validate_" + category.to_s.chop).to_sym
            settings[category].each do |name, details|
              if details.is_a?(Hash)
                send(validate_method, details.merge(:name => name.to_s))
              else
                object_type = category[0..-2]
                invalid(details, "#{object_type} must be a hash")
              end
            end
          else
            invalid(settings[category], "#{category} must be a hash")
          end
        end
      end

      # Record an invalid object with a message.
      #
      # @param object [Object] invalid object.
      # @param message [String] message explaining why the object is
      #   invalid.
      # @return [Array] current validation failures.
      def invalid(object, message)
        @failures << {
          :object => object,
          :message => message
        }
      end
    end
  end
end
