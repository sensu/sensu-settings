module Sensu
  module Settings
    module Validators
      module Extension
        # Validate a Sensu extension definition.
        # Validates: gem, version
        #
        # @param filter [Hash] sensu extension definition.
        def validate_extension(extension)
          must_be_a_string_if_set(extension[:gem]) ||
            invalid(extension, "extension gem must be a string")
          must_be_a_string_if_set(extension[:version]) ||
            invalid(extension, "extension version must be a string")
        end
      end
    end
  end
end
