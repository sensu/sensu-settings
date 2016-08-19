module Sensu
  module Settings
    module Validators
      module TimeWindow
        # Validate time window condition
        # Validates: begin, end
        #
        # @param definition [Hash] sensu definition.
        # @param scope [String] definition scope to validate.
        # @param attribute [String] definition attribute to validate.
        # @param condition [Hash] to have begin and end validated.
        def validate_time_window_condition(definition, scope, attribute, condition)
          if is_a_hash?(condition)
            must_be_time(condition[:begin], condition[:end]) ||
              invalid(definition, "#{scope} #{attribute} begin and end times must be valid")
          else
            invalid(definition, "#{scope} #{attribute} must be a hash")
          end
        end

        # Validate time windows days
        # Validates: days
        #
        # @param definition [Hash] sensu definition.
        # @param scope [String] definition scope to validate.
        # @param attribute [String] definition attribute to validate.
        # @param days [String] time window days to validate.
        def validate_time_windows_days(definition, scope, attribute, days)
          valid_days = [:all, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday]
          if must_be_either(valid_days, days.keys)
            days.each do |day, conditions|
              if is_an_array?(conditions)
                conditions.each do |condition|
                  validate_time_window_condition(definition, scope, attribute, condition)
                end
              else
                invalid(definition, "#{scope} #{attribute} #{day} time windows must be in an array")
              end
            end
          else
            invalid(definition, "#{scope} #{attribute} days must be valid days of the week or 'all'")
          end
        end

        # Validate time windows
        # Validates: days
        #
        # @param definition [Hash] sensu definition.
        # @param scope [String] definition scope to validate.
        # @param attribute [String] definition attribute to validate.
        def validate_time_windows(definition, scope, attribute)
          if is_a_hash?(definition[attribute])
            days = definition[attribute][:days]
            if is_a_hash?(days)
              if !days.empty?
                validate_time_windows_days(definition, scope, attribute, days)
              else
                invalid(definition, "#{scope} #{attribute} days must include at least one day of the week or 'all'")
              end
            else
              invalid(definition, "#{scope} #{attribute} days must be a hash")
            end
          else
            invalid(definition, "#{scope} #{attribute} must be a hash")
          end
        end
      end
    end
  end
end
