require "sensu/settings/rules"
require "sensu/settings/constants"

module Sensu
  module Settings
    class Validator
      include Rules

      # @!attribute [r] failures
      #   @return [Array] validation failures.
      attr_reader :failures

      def initialize
        @failures = []
      end

      # Run the validator.
      #
      # @param settings [Hash] settings to validate.
      # @return [Array] validation failures.
      def run(settings)
        CATEGORIES.each do |category|
          must_be_a_hash(settings[category]) ||
            invalid(settings[category], "#{category} must be a hash")
          if is_a_hash?(settings[category])
            settings[category].each do |object|
              send(("validate_" + category.to_s.chop).to_sym, object)
            end
          end
        end
        @failures
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

      # Validate a Sensu check definition.
      #
      # @param check [Object] sensu check definition (hash).
      def validate_check(check)
        must_be_a_string(check[:name]) ||
          invalid(check, "check name must be a string")
        must_match_regex(/^[\w\.-]+$/, check[:name]) ||
          invalid(check, "check name cannot contain spaces or special characters")
        must_be_a_string(check[:command]) ||
          invalid(check, "check command must be a string")
        (must_be_an_integer(check[:interval]) && check[:interval] > 0) ||
          invalid(check, "check is missing interval")
      end
    end
  end
end
