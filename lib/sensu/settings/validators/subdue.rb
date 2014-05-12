module Sensu
  module Settings
    module Validators
      module Subdue
        # Validate subdue time.
        # Validates: begin, end
        #
        # @param scope [String] definition scope to report under.
        # @param definition [Hash] sensu definition.
        # @param object [Hash] to have begin and end validated.
        def validate_subdue_time(scope, definition, object)
          if is_a_hash?(object)
            if either_are_set?(object[:begin], object[:end])
              must_be_time(object[:begin], object[:end]) ||
                invalid(definition, "#{scope} begin and end times must be valid")
            end
          else
            invalid(definition, "#{scope} must be a hash")
          end
        end

        # Validate subdue days.
        # Validates: days
        #
        # @param definition [Hash] sensu definition.
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
        # @param definition [Hash] sensu definition.
        def validate_subdue_exceptions(definition)
          subdue = definition[:subdue]
          must_be_an_array_if_set(subdue[:exceptions]) ||
            invalid(definition, "subdue exceptions must be an array")
          if is_an_array?(subdue[:exceptions])
            subdue[:exceptions].each do |exception|
              validate_subdue_time("subdue exceptions", definition, exception)
            end
          end
        end

        # Validate Sensu subdue, for either a check or handler definition.
        #
        # @param definition [Hash] sensu definition.
        def validate_subdue(definition)
          subdue = definition[:subdue]
          validate_subdue_time("subdue", definition, subdue)
          if is_a_hash?(subdue)
            must_be_either_if_set(%w[handler publisher], subdue[:at]) ||
              invalid(definition, "subdue at must be either handler or publisher")
            validate_subdue_days(definition)
            validate_subdue_exceptions(definition)
          end
        end
      end
    end
  end
end
