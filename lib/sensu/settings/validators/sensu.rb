module Sensu
  module Settings
    module Validators
      module Sensu
        # Validate Sensu spawn.
        # Validates: limit
        #
        # @param sensu [Hash] sensu definition.
        def validate_sensu_spawn(sensu)
          spawn = sensu[:spawn]
          if is_a_hash?(spawn)
            if is_an_integer?(spawn[:limit])
              spawn[:limit] > 0 ||
                invalid(sensu, "sensu spawn limit must be greater than 0")
            else
              invalid(sensu, "sensu spawn limit must be an integer")
            end
          else
            invalid(sensu, "sensu spawn must be a hash")
          end
        end

        # Validate a Sensu definition.
        # Validates: spawn
        #
        # @param sensu [Hash] sensu definition.
        def validate_sensu(sensu)
          if is_a_hash?(sensu)
            validate_sensu_spawn(sensu)
          else
            invalid(sensu, "sensu must be a hash")
          end
        end
      end
    end
  end
end
