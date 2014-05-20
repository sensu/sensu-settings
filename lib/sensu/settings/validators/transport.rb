module Sensu
  module Settings
    module Validators
      module Transport
        # Validate a Sensu transport definition.
        # Validates: name
        #
        # @param transport [Hash] sensu transport definition.
        def validate_transport(transport)
          must_be_a_hash_if_set(transport) ||
            invalid(transport, "transport must be a hash")
          if is_a_hash?(transport)
            must_be_a_string_if_set(transport[:name]) ||
              invalid(transport, "transport name must be a string")
          end
        end
      end
    end
  end
end
