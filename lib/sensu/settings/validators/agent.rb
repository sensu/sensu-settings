module Sensu
  module Settings
    module Validators
      module Agent
        # Validate agent subscriptions.
        # Validates: subscriptions
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_subscriptions(agent)
          if is_an_array?(agent[:subscriptions])
            items_must_be_strings(agent[:subscriptions]) ||
              invalid(agent, "agent subscriptions must each be a string")
          else
            invalid(agent, "agent subscriptions must be an array")
          end
        end

        # Validate agent safe mode.
        # Validates: safe_mode
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_safe_mode(agent)
          must_be_boolean_if_set(agent[:safe_mode]) ||
            invalid(agent, "agent safe_mode must be boolean")
        end

        # Validate agent socket.
        # Validates: socket (bind, port)
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_socket(agent)
          must_be_a_hash_if_set(agent[:socket]) ||
            invalid(agent, "agent socket must be a hash")
          if is_a_hash?(agent[:socket])
            must_be_a_string_if_set(agent[:socket][:bind]) ||
              invalid(agent, "agent socket bind must be a string")
            must_be_an_integer_if_set(agent[:socket][:port]) ||
              invalid(agent, "agent socket port must be an integer")
          end
        end

        # Validate agent keepalive handlers.
        # Validates: keepalive (handler, handlers)
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_keepalive_handlers(agent)
          must_be_a_string_if_set(agent[:keepalive][:handler]) ||
            invalid(agent, "agent keepalive handler must be a string")
          must_be_an_array_if_set(agent[:keepalive][:handlers]) ||
            invalid(agent, "agent keepalive handlers must be an array")
          if is_an_array?(agent[:keepalive][:handlers])
            items_must_be_strings(agent[:keepalive][:handlers]) ||
              invalid(agent, "agent keepalive handlers must each be a string")
          end
        end

        # Validate agent keepalive thresholds.
        # Validates: keepalive (thresholds)
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_keepalive_thresholds(agent)
          thresholds = agent[:keepalive][:thresholds]
          must_be_a_hash_if_set(thresholds) ||
            invalid(agent, "agent keepalive thresholds must be a hash")
          if is_a_hash?(thresholds)
            must_be_an_integer_if_set(thresholds[:warning]) ||
              invalid(agent, "agent keepalive warning threshold must be an integer")
            must_be_an_integer_if_set(thresholds[:critical]) ||
              invalid(agent, "agent keepalive critical threshold must be an integer")
          end
        end

        # Validate agent keepalive.
        # Validates: keepalive
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_keepalive(agent)
          must_be_a_hash_if_set(agent[:keepalive]) ||
            invalid(agent, "agent keepalive must be a hash")
          if is_a_hash?(agent[:keepalive])
            validate_agent_keepalive_handlers(agent)
            validate_agent_keepalive_thresholds(agent)
          end
        end

        # Validate agent redact.
        # Validates: redact
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_redact(agent)
          must_be_an_array_if_set(agent[:redact]) ||
            invalid(agent, "agent redact must be an array")
          if is_an_array?(agent[:redact])
            items_must_be_strings(agent[:redact]) ||
              invalid(agent, "agent redact keys must each be a string")
          end
        end

        # Validate agent represents section.
        # Validates: represents
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_represents(agent)
          must_be_a_hash_if_set(agent[:represents]) ||
            invalid(agent, "agent represents must be a hash")
          if is_a_hash?(agent[:represents])
            either_are_set?(agent[:represents][:name], agent[:represents][:address])
            must_be_a_string_if_set(agent[:represents][:name]) ||
              invalid(agent, "agent represents name must be a string")
            must_match_regex_if_set(/^[\w\.-]+$/, agent[:represents][:name]) ||
              invalid(agent, "agent represents name cannot contain spaces or special characters")
            must_be_a_string(agent[:address]) ||
              invalid(agent, "agent represents address must be a string")
          end
        end

        # Validate agent discovery section.
        # Validates: represents
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_discovery(agent)
          must_be_a_hash_if_set(agent[:discovery]) ||
            invalid(agent, "agent discovery must be a hash")
          if is_a_hash?(agent[:discovery])
            either_are_set?(agent[:discovery][:command], agent[:discovery][:extension])
            must_be_a_string_if_set(agent[:discovery][:command]) ||
              invalid(agent, "agent discovery command must be a string")
            must_be_a_string_if_set(agent[:discovery][:extension]) ||
              invalid(agent, "agent discovery command must be a string")
            must_be_a_numeric_if_set(agent[:discovery][:timeout]) ||
              invalid(agent, "agent discovery timeout must be numeric")
            must_be_a_numeric_if_set(agent[:discovery][:interval]) ||
              invalid(anget, "agent discovery interval must be numeric")
          end
        end

        # Validate configuration restrictions in agent e.g. represents and
        # discovery cannot both be present at the same time in the config.
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent_restrictions(agent)
          only_one_is_set?(agent[:represents], agent[:discovery]) ||
            invalid(agent, "agent cannot have both a represents and a discovery section")
        end

        # Validate a Sensu agent definition.
        # Validates: name, address, safe-mode, socket, represents, discovery,
        # subscriptions, redact, keepalive
        #
        # @param agent [Hash] sensu agent definition.
        def validate_agent(agent)
          must_be_a_hash(agent) ||
            invalid(agent, "agent must be a hash")
          if is_a_hash?(agent)
            must_be_a_string(agent[:name]) ||
              invalid(agent, "agent name must be a string")
            must_match_regex(/^[\w\.-]+$/, agent[:name]) ||
              invalid(agent, "agent name cannot contain spaces or special characters")
            must_be_a_string(agent[:address]) ||
              invalid(agent, "agent address must be a string")
            validate_agent_restrictions(agent)
            validate_agent_safe_mode(agent)
            validate_agent_socket(agent)
            validate_agent_represents(agent)
            validate_agent_discovery(agent)
            validate_agent_subscriptions(agent)
            validate_agent_keepalive(agent)
            validate_agent_redact(agent)
          end
        end
      end
    end
  end
end
