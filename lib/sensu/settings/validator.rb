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
      # @return [Array] validation failures.
      def run(settings)
        CATEGORIES.each do |category|
          if is_a_hash?(settings[category])
            validate_method = ("validate_" + category.to_s.chop).to_sym
            settings[category].each do |name, details|
              send(validate_method, details.merge(:name => name.to_s))
            end
          else
            invalid(settings[category], "#{category} must be a hash")
          end
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
