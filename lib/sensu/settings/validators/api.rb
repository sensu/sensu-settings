module Sensu
  module Settings
    module Validators
      module API
        # Validate API authentication.
        # Validates: user, password
        #
        # @param api [Hash] sensu api definition.
        def validate_api_authentication(api)
          if either_are_set?(api[:user], api[:password])
            must_be_a_string(api[:user]) ||
              invalid(api, "api user must be a string")
            must_be_a_string(api[:password]) ||
              invalid(api, "api password must be a string")
          end
        end

        # Validate API endpoints.
        # Validates: endpoints
        #
        # @param api [Hash] sensu api definition.
        def validate_api_endpoints(api)
          if is_an_array?(api[:endpoints])
            api[:endpoints].each do |endpoint|
              if is_a_hash?(endpoint)
                if endpoint[:url]
                  must_be_a_string(endpoint[:url]) ||
                    invalid(api, "api endpoint url must be a string")
                else
                  must_be_a_string(endpoint[:host]) ||
                    invalid(api, "api endpoint host must be a string")
                  must_be_an_integer(endpoint[:port]) ||
                    invalid(api, "api endpoint port must be an integer")
                  must_be_boolean_if_set(endpoint[:ssl]) ||
                    invalid(api, "api endpoint ssl must be a boolean")
                end
              else
                invalid(api, "api endpoints must each be a hash")
              end
            end
          else
            invalid(api, "api endpoints must be an array")
          end
        end

        # Validate a Sensu API definition.
        # Validates: port, bind
        #
        # @param api [Hash] sensu api definition.
        def validate_api(api)
          must_be_a_hash_if_set(api) ||
            invalid(api, "api must be a hash")
          if is_a_hash?(api)
            must_be_an_integer_if_set(api[:port]) ||
              invalid(api, "api port must be an integer")
            must_be_a_string_if_set(api[:bind]) ||
              invalid(api, "api bind must be a string")
            validate_api_authentication(api)
            validate_api_endpoints(api) if api[:endpoints]
          end
        end
      end
    end
  end
end
