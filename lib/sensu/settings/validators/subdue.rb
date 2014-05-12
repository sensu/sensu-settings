module Sensu
  module Settings
    module Validators
      module Subdue
        # Validate subdue time.
        # Validates: begin, end
        #
        # @param definition [Object] sensu definition (hash).
        def validate_subdue_time(definition)
          subdue = definition[:subdue]
          if either_are_set?(subdue[:begin], subdue[:end])
            must_be_time(subdue[:begin], subdue[:end]) ||
              invalid(definition, "subdue begin and end times must be valid")
          end
        end

        # Validate subdue days.
        # Validates: days
        #
        # @param definition [Object] sensu definition (hash).
        def validate_subdue_days(definition)
          subdue = definition[:subdue]
          must_be_an_array_if_set(subdue[:days]) ||
            invalid(definition, "subdue days must be an array")
          if is_an_array?(subdue[:days])
            days = %w[sunday monday tuesday wednesday thursday friday saturday]
            must_be_either(days, subdue[:days]) ||
              invalid(definition, "subdue days must be valid days of the week")
          end
        end

        # Validate subdue exceptions.
        # Validates: exceptions (begin, end)
        #
        # @param definition [Object] sensu definition (hash).
        def validate_subdue_exceptions(definition)
          subdue = definition[:subdue]
          must_be_an_array_if_set(subdue[:exceptions]) ||
            invalid(definition, "subdue exceptions must be an array")
          if is_an_array?(subdue[:exceptions])
            subdue[:exceptions].each do |exception|
              must_be_a_hash(exception) ||
                invalid(definition, "subdue exceptions must each be a hash")
              if is_a_hash?(exception)
                if either_are_set?(exception[:begin], exception[:end])
                  must_be_time(exception[:begin], exception[:end]) ||
                    invalid(definition, "subdue exception begin and end times must be valid")
                end
              end
            end
          end
        end

        # Validate Sensu subdue, for either a check or handler definition.
        #
        # @param definition [Object] sensu definition (hash).
        def validate_subdue(definition)
          subdue = definition[:subdue]
          must_be_a_hash(subdue) ||
            invalid(definition, "subdue must be a hash")
          if is_a_hash?(subdue)
            must_be_either_if_set(%w[handler publisher], subdue[:at]) ||
              invalid(definition, "subdue at must be either handler or publisher")
            validate_subdue_time(definition)
            validate_subdue_days(definition)
            validate_subdue_exceptions(definition)
          end
        end
      end
    end
  end
end
