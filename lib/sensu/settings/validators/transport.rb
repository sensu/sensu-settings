module Sensu
  module Settings
    module Validators
      module Transport
        # Validate a Sensu transport definition.
        # Validates: name
        #
        # @param transport [Hash] sensu transport definition.
        def validate_transport(transport)
          if is_a_hash?(transport)
            must_be_a_string_if_set(transport[:name]) ||
              invalid(transport, "transport name must be a string")
            must_be_boolean_if_set(transport[:reconnect_on_error]) ||
              invalid(transport, "transport reconnect_on_error must be boolean")
          else
            invalid(transport, "transport must be a hash")
          end
        end
      end
    end
  end
end
