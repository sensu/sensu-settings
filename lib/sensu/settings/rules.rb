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
      alias_method :is_an_array?, :must_be_an_array

      # Check that a value is an array, if set (not nil).
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_an_array_if_set(value)
        value.nil? ? true : value.is_a?(Array)
      end

      # Check that a value is a string.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_string(value)
        value.is_a?(String)
      end

      # Check that a value is a string, if set (not nil).
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_string_if_set(value)
        value.nil? ? true : value.is_a?(String)
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

      # Check that a value is numeric, if set (not nil).
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_numeric_if_set(value)
        value.nil? ? true : value.is_a?(Numeric)
      end

      # Check that a value matches a regular expression.
      #
      # @param regex [Regexp] pattern to compare with value.
      # @param value [Object] to check if matches pattern.
      # @return [TrueClass, FalseClass]
      def must_match_regex(regex, value)
        value =~ regex
      end

      # Check if a value is boolean, if set (no nil).
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_boolean_if_set(value)
        value.nil? ? true : (!!value == value)
      end

      # Check that value items are all strings and not empty.
      #
      # @param value [Array] with items to check.
      # @return [TrueClass, FalseClass]
      def items_must_be_strings(value)
        value.all? do |item|
          item.is_a?(String) && !item.empty?
        end
      end
    end
  end
end
