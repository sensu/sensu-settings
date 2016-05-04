module Sensu
  module Settings
    module Validators
      module Client
        # Validate client subscriptions.
        # Validates: subscriptions
        #
        # @param client [Hash] sensu client definition.
        def validate_client_subscriptions(client)
          if is_an_array?(client[:subscriptions])
            items_must_be_strings(client[:subscriptions]) ||
              invalid(client, "client subscriptions must each be a string")
          else
            invalid(client, "client subscriptions must be an array")
          end
        end

        # Validate client safe mode.
        # Validates: safe_mode
        #
        # @param client [Hash] sensu client definition.
        def validate_client_safe_mode(client)
          must_be_boolean_if_set(client[:safe_mode]) ||
            invalid(client, "client safe_mode must be boolean")
        end

        # Validate client socket.
        # Validates: socket (bind, port)
        #
        # @param client [Hash] sensu client definition.
        def validate_client_socket(client)
          must_be_a_hash_if_set(client[:socket]) ||
            invalid(client, "client socket must be a hash")
          if is_a_hash?(client[:socket])
            must_be_a_string_if_set(client[:socket][:bind]) ||
              invalid(client, "client socket bind must be a string")
            must_be_an_integer_if_set(client[:socket][:port]) ||
              invalid(client, "client socket port must be an integer")
          end
        end

        # Validate client keepalives.
        # Validates: keepalives
        #
        # @param client [Hash] sensu client definition.
        def validate_client_keepalives(client)
          must_be_boolean_if_set(client[:keepalives]) ||
            invalid(client, "client keepalives must be boolean")
        end

        # Validate client keepalive handlers.
        # Validates: keepalive (handler, handlers)
        #
        # @param client [Hash] sensu client definition.
        def validate_client_keepalive_handlers(client)
          must_be_a_string_if_set(client[:keepalive][:handler]) ||
            invalid(client, "client keepalive handler must be a string")
          must_be_an_array_if_set(client[:keepalive][:handlers]) ||
            invalid(client, "client keepalive handlers must be an array")
          if is_an_array?(client[:keepalive][:handlers])
            items_must_be_strings(client[:keepalive][:handlers]) ||
              invalid(client, "client keepalive handlers must each be a string")
          end
        end

        # Validate client keepalive thresholds.
        # Validates: keepalive (thresholds)
        #
        # @param client [Hash] sensu client definition.
        def validate_client_keepalive_thresholds(client)
          thresholds = client[:keepalive][:thresholds]
          must_be_a_hash_if_set(thresholds) ||
            invalid(client, "client keepalive thresholds must be a hash")
          if is_a_hash?(thresholds)
            must_be_an_integer_if_set(thresholds[:warning]) ||
              invalid(client, "client keepalive warning threshold must be an integer")
            must_be_an_integer_if_set(thresholds[:critical]) ||
              invalid(client, "client keepalive critical threshold must be an integer")
          end
        end

        # Validate client keepalive.
        # Validates: keepalive
        #
        # @param client [Hash] sensu client definition.
        def validate_client_keepalive(client)
          must_be_a_hash_if_set(client[:keepalive]) ||
            invalid(client, "client keepalive must be a hash")
          if is_a_hash?(client[:keepalive])
            validate_client_keepalive_handlers(client)
            validate_client_keepalive_thresholds(client)
          end
        end

        # Validate client redact.
        # Validates: redact
        #
        # @param client [Hash] sensu client definition.
        def validate_client_redact(client)
          must_be_an_array_if_set(client[:redact]) ||
            invalid(client, "client redact must be an array")
          if is_an_array?(client[:redact])
            items_must_be_strings(client[:redact]) ||
              invalid(client, "client redact keys must each be a string")
          end
        end

        # Validate client signature.
        # Validates: signature
        #
        # @param client [Hash] sensu client definition.
        def validate_client_signature(client)
          must_be_a_string_if_set(client[:signature]) ||
            invalid(client, "client signature must be a string")
        end

        # Validate client registration handlers.
        # Validates: registration (handler, handlers)
        #
        # @param client [Hash] sensu client definition.
        def validate_client_registration_handlers(client)
          must_be_a_string_if_set(client[:registration][:handler]) ||
            invalid(client, "client registration handler must be a string")
          must_be_an_array_if_set(client[:registration][:handlers]) ||
            invalid(client, "client registration handlers must be an array")
          if is_an_array?(client[:registration][:handlers])
            items_must_be_strings(client[:registration][:handlers]) ||
              invalid(client, "client registration handlers must each be a string")
          end
        end

        # Validate client registration.
        # Validates: registration
        #
        # @param client [Hash] sensu client definition.
        def validate_client_registration(client)
          must_be_a_hash_if_set(client[:registration]) ||
            invalid(client, "client registration must be a hash")
          if is_a_hash?(client[:registration])
            validate_client_registration_handlers(client)
          end
        end

        # Validate a Sensu client definition.
        # Validates: name, address, safe_mode
        #
        # @param client [Hash] sensu client definition.
        def validate_client(client)
          must_be_a_hash(client) ||
            invalid(client, "client must be a hash")
          if is_a_hash?(client)
            must_be_a_string(client[:name]) ||
              invalid(client, "client name must be a string")
            must_match_regex(/^[\w\.-]+$/, client[:name]) ||
              invalid(client, "client name cannot contain spaces or special characters")
            must_be_a_string(client[:address]) ||
              invalid(client, "client address must be a string")
            validate_client_safe_mode(client)
            validate_client_subscriptions(client)
            validate_client_socket(client)
            validate_client_keepalives(client)
            validate_client_keepalive(client)
            validate_client_redact(client)
            validate_client_signature(client)
            validate_client_registration(client)
          end
        end
      end
    end
  end
end
