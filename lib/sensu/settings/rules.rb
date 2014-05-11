module Sensu
  module Settings
    module Rules
      # Check that a value is a hash.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_hash(value)
        value.is_a?(Hash)
      end
      alias_method :is_a_hash?, :must_be_a_hash

      # Check that a value is an array.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_an_array(value)
        value.is_a?(Array)
      end

      # Check that a value is a string.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_string(value)
        value.is_a?(String)
      end

      # Check that a value is an integer.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_an_integer(value)
        value.is_a?(Integer)
      end

      # Check that a value is numeric.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_numeric(value)
        value.is_a?(Numeric)
      end

      # Check that a value matches a regular expression.
      #
      # @param regex [Regexp] pattern to compare with value.
      # @param value [Object] to check if matches pattern.
      # @return [TrueClass, FalseClass]
      def must_match_regex(regex, value)
        value =~ regex
      end
    end
  end
end
