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

        # Validate Sensu keepalives thresholds.
        # Validates: warning, critical
        #
        # @param sensu [Hash] sensu definition.
        def validate_sensu_keepalives_thresholds(sensu)
          thresholds = sensu[:keepalives][:thresholds]
          must_be_a_hash_if_set(thresholds) ||
            invalid(sensu, "sensu keepalives thresholds must be a hash")
          if is_a_hash?(thresholds)
            must_be_an_integer_if_set(thresholds[:warning]) ||
              invalid(sensu, "sensu keepalives warning threshold must be an integer")
            must_be_an_integer_if_set(thresholds[:critical]) ||
              invalid(sensu, "sensu keepalives critical threshold must be an integer")
          end
        end

        # Validate Sensu keepalives handlers.
        # Validates: handler, handlers
        #
        # @param sensu [Hash] sensu definition.
        def validate_sensu_keepalives_handlers(sensu)
          must_be_a_string_if_set(sensu[:keepalives][:handler]) ||
            invalid(sensu, "sensu keepalives handler must be a string")
          must_be_an_array_if_set(sensu[:keepalives][:handlers]) ||
            invalid(sensu, "sensu keepalives handlers must be an array")
          if is_an_array?(sensu[:keepalives][:handlers])
            items_must_be_strings(sensu[:keepalives][:handlers]) ||
              invalid(sensu, "sensu keepalives handlers must each be a string")
          end
        end

        # Validate Sensu keepalives.
        # Validates: thresholds (warning, critical), handler, handlers
        #
        # @param sensu [Hash] sensu definition.
        def validate_sensu_keepalives(sensu)
          if is_a_hash?(sensu[:keepalives])
            validate_sensu_keepalives_thresholds(sensu)
            validate_sensu_keepalives_handlers(sensu)
          else
            invalid(sensu, "sensu keepalives must be a hash")
          end
        end

        # Validate Sensu server.
        # Validates: server results_pipe, keepalives_pipe
        #
        # @param sensu [Hash] sensu definition.
        def validate_sensu_server(sensu)
          if is_a_hash?(sensu[:server])
            must_be_a_string_if_set(sensu[:server][:results_pipe]) ||
              invalid(sensu, "sensu server results_pipe must be a string")
            must_be_a_string_if_set(sensu[:server][:keepalives_pipe]) ||
              invalid(sensu, "sensu server keepalives_pipe must be a string")
            must_be_an_integer_if_set(sensu[:server][:max_message_size]) ||
              invalid(sensu, "sensu server max_message_size must be an integer")
          else
            invalid(sensu, "sensu server must be a hash")
          end
        end

        # Validate a Sensu definition.
        # Validates: spawn, keepalives
        #
        # @param sensu [Hash] sensu definition.
        def validate_sensu(sensu)
          if is_a_hash?(sensu)
            validate_sensu_spawn(sensu)
            validate_sensu_keepalives(sensu)
            validate_sensu_server(sensu) if sensu[:server]
            must_be_boolean_if_set(sensu[:global_error_handler]) ||
              invalid(sensu, "sensu global_error_handler must be boolean")
          else
            invalid(sensu, "sensu must be a hash")
          end
        end
      end
    end
  end
end
