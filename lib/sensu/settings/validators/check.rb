module Sensu
  module Settings
    module Validators
      module Check
        # Validate check scheduling.
        # Validates: interval, standalone, subscribers
        #
        # @param check [Hash] sensu check definition.
        def validate_check_scheduling(check)
          (must_be_an_integer(check[:interval]) && check[:interval] > 0) ||
            invalid(check, "check interval must be an integer")
          must_be_boolean_if_set(check[:standalone]) ||
            invalid(check, "check standalone must be boolean")
          unless check[:standalone]
            if is_an_array?(check[:subscribers])
              items_must_be_strings(check[:subscribers]) ||
                invalid(check, "check subscribers must each be a string")
            else
              invalid(check, "check subscribers must be an array")
            end
          end
        end

        # Validate check handling.
        # Validates: handler, handlers
        #
        # @param check [Hash] sensu check definition.
        def validate_check_handling(check)
          must_be_a_string_if_set(check[:handler]) ||
            invalid(check, "check handler must be a string")
          must_be_an_array_if_set(check[:handlers]) ||
            invalid(check, "check handlers must be an array")
          if is_an_array?(check[:handlers])
            items_must_be_strings(check[:handlers]) ||
              invalid(check, "check handlers must each be a string")
          end
        end

        # Validate check flap detection.
        # Validates: low_flap_threshold, high_flap_threshold
        #
        # @param check [Hash] sensu check definition.
        def validate_check_flap_detection(check)
          if either_are_set?(check[:low_flap_threshold], check[:high_flap_threshold])
            must_be_an_integer(check[:low_flap_threshold]) ||
              invalid(check, "check low flap threshold must be an integer")
            must_be_an_integer(check[:high_flap_threshold]) ||
              invalid(check, "check high flap threshold must be an integer")
          end
        end

        # Validate a Sensu check definition.
        #
        # @param check [Hash] sensu check definition.
        def validate_check(check)
          must_be_a_string(check[:name]) ||
            invalid(check, "check name must be a string")
          must_match_regex(/^[\w\.-]+$/, check[:name]) ||
            invalid(check, "check name cannot contain spaces or special characters")
          must_be_a_string(check[:command]) ||
            invalid(check, "check command must be a string")
          must_be_a_numeric_if_set(check[:timeout]) ||
            invalid(check, "check timeout must be numeric")
          validate_check_scheduling(check)
          validate_check_handling(check)
          validate_check_flap_detection(check)
          if check[:subdue]
            validate_subdue(check)
          end
        end
      end
    end
  end
end
