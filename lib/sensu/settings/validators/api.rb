module Sensu
  module Settings
    module Validators
      module API
        # Validate a Sensu API definition.
        # Validates: attributes, negate
        #
        # @param api [Hash] sensu api definition.
        def validate_api(api)
          if is_a_hash?(api)
            must_be_an_integer(api[:port]) ||
              invalid(api, "api port must be an integer")
            must_be_a_string_if_set(api[:bind]) ||
              invalid(api, "api bind must be a string")
            if either_are_set?(api[:user], api[:password])
              must_be_a_string(api[:user]) ||
                invalid(api, "api user must be a string")
              must_be_a_string(api[:password]) ||
                invalid(api, "api password must be a string")
            end
          else
            invalid(api, "api must be a hash")
          end
        end
      end
    end
  end
end
