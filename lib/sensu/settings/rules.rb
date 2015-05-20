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

      # Check that a value is a hash, if set (not nil).
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_hash_if_set(value)
        value.nil? ? true : must_be_a_hash(value)
      end

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
        value.nil? ? true : must_be_an_array(value)
      end

      # Check that a value is a string.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_string(value)
        value.is_a?(String)
      end
      alias_method :is_a_string?, :must_be_a_string

      # Check that a value is a string, if set (not nil).
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_a_string_if_set(value)
        value.nil? ? true : must_be_a_string(value)
      end

      # Check that a value is an integer.
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_an_integer(value)
        value.is_a?(Integer)
      end
      alias_method :is_an_integer?, :must_be_an_integer

      # Check that a value is an integer, if set (not nil).
      #
      # @param value [Object] to check.
      # @return [TrueClass, FalseClass]
      def must_be_an_integer_if_set(value)
        value.nil? ? true : must_be_an_integer(value)
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
        value.nil? ? true : must_be_a_numeric(value)
      end

      # Check that a value matches a regular expression.
      #
      # @param regex [Regexp] pattern to compare with value.
      # @param value [Object] to check if matches pattern.
      # @return [TrueClass, FalseClass]
      def must_match_regex(regex, value)
        (value =~ regex) == 0
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

      # Check if either of the values are set (not nil).
      #
      # @param values [Array<Object>] to check if not nil.
      # @return [TrueClass, FalseClass]
      def either_are_set?(*values)
        values.any? do |value|
          !value.nil?
        end
      end

      # Check if values are valid times (can be parsed).
      #
      # @param values [Array<Object>] to check if valid time.
      # @return [TrueClass, FalseClass]
      def must_be_time(*values)
        values.all? do |value|
          Time.parse(value) rescue false
        end
      end

      # Check if values are allowed.
      #
      # @param allowed [Array<Object>] allowed values.
      # @param values [Array<Object>] to check if allowed.
      # @return [TrueClass, FalseClass]
      def must_be_either(allowed, *values)
        values.flatten.all? do |value|
          allowed.include?(value)
        end
      end

      # Check if values are allowed, if set (not nil).
      #
      # @param allowed [Array<Object>] allowed values.
      # @param values [Array<Object>] to check if allowed.
      # @return [TrueClass, FalseClass]
      def must_be_either_if_set(allowed, *values)
        values[0].nil? ? true : must_be_either(allowed, values)
      end
    end
  end
end
