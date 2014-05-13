module Sensu
  module Settings
    module Validators
      module Filter
        # Validate a Sensu filter definition.
        # Validates: attributes, negate
        #
        # @param filter [Hash] sensu filter definition.
        def validate_filter(filter)
          must_be_boolean_if_set(filter[:negate]) ||
            invalid(filter, "filter negate must be boolean")
          must_be_a_hash(filter[:attributes]) ||
            invalid(filter, "filter attributes must be a hash")
        end
      end
    end
  end
end
