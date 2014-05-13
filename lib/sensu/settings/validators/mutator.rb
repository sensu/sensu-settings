module Sensu
  module Settings
    module Validators
      module Mutator
        # Validate a Sensu mutator definition.
        # Validates:
        #
        # @param mutator [Hash] sensu mutator definition.
        def validate_mutator(mutator)
          must_be_a_string(mutator[:command]) ||
            invalid(mutator, "mutator command must be a string")
          must_be_a_numeric_if_set(mutator[:timeout]) ||
            invalid(mutator, "mutator timeout must be numeric")
        end
      end
    end
  end
end
