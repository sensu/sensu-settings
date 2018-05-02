module Sensu
  module Settings
    module Validators
      module Tessen
        # Validate a Tessen definition.
        # Validates: enabled, identity_key
        #
        # @param tessen [Hash] tessen definition.
        def validate_tessen(tessen)
          must_be_a_hash_if_set(tessen) ||
            invalid(tessen, "tessen must be a hash")
          if is_a_hash?(tessen)
            must_be_boolean_if_set(tessen[:enabled]) ||
              invalid(tessen, "tessen enabled must be boolean")
            must_be_a_string_if_set(tessen[:identity_key]) ||
              invalid(check, "tessen identity_key must be a string")
          end
        end
      end
    end
  end
end
