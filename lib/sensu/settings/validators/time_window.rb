module Sensu
  module Settings
    module Validators
      module TimeWindow
        # Validate time window condition
        # Validates: begin, end
        #
        # @param definition [Hash] sensu definition.
        # @param scope [String] definition scope to validate.
        # @param condition [Hash] to have begin and end validated.
        def validate_time_window_condition(definition, scope, condition)
          if is_a_hash?(condition)
            if either_are_set?(condition[:begin], condition[:end])
              must_be_time(condition[:begin], condition[:end]) ||
                invalid(definition, "#{scope} begin and end times must be valid")
            end
          else
            invalid(definition, "#{scope} must be a hash")
          end
        end

        # Validate time windows
        # Validates: days
        #
        # @param definition [Hash] sensu definition.
        # @param scope [String] definition scope to validate.
        # @param days [String] time window days to validate.
        def validate_time_windows_days(definition, scope, days)
          valid_days = [:all, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
          if must_be_either(valid_days, days.keys)
            days.each do |day, conditions|
              if is_an_array?(conditions)
                conditions.each do |condition|
                  validate_time_window_condition(definition, scope, condition)
                end
              else
                invalid(definition, "#{scope} #{day} time windows must be in an array")
              end
            end
          else
            invalid(definition, "#{scope} days must be valid days of the week or 'all'")
          end
        end

        # Validate time windows
        # Validates: days
        #
        # @param definition [Hash] sensu definition.
        # @param scope [String] definition scope to validate.
        def validate_time_windows(definition, scope)
          if is_a_hash?(definition[scope])
            days = definition[scope][:days]
            must_be_a_hash_if_set(days) ||
              invalid(definition, "#{scope} days must be a hash")
            if is_a_hash?(days)
              validate_time_windows_days(definition, scope, days)
            end
          else
            invalid(definition, "#{scope} must be a hash")
          end
        end
      end
    end
  end
end
