require "parse-cron"

module Sensu
  module Settings
    module Validators
      module Check
        # Validate check name.
        # Validates: name
        #
        # @param check [Hash] sensu check definition.
        def validate_check_name(check)
          must_be_a_string(check[:name]) ||
            invalid(check, "check name must be a string")
          must_match_regex(/\A[\w\.-]+\z/, check[:name]) ||
            invalid(check, "check name cannot contain spaces or special characters")
        end

        # Validate check execution.
        # Validates: command, extension, timeout
        #
        # @param check [Hash] sensu check definition.
        def validate_check_execution(check)
          must_be_a_string_if_set(check[:command]) ||
            invalid(check, "check command must be a string")
          must_be_a_string_if_set(check[:extension]) ||
            invalid(check, "check extension must be a string")
          (!check[:command].nil? ^ !check[:extension].nil?) ||
            invalid(check, "either check command or extension must be set")
          must_be_a_numeric_if_set(check[:timeout]) ||
            invalid(check, "check timeout must be numeric")
        end

        # Validate check source.
        # Validates: source
        #
        # @param check [Hash] sensu check definition.
        def validate_check_source(check)
          if is_a_string?(check[:source])
            must_match_regex(/\A[\w\.-]+\z/, check[:source]) ||
              invalid(check, "check source cannot contain spaces or special characters")
          else
            invalid(check, "check source must be a string")
          end
        end

        # Validate check cron.
        # Validates: cron
        #
        # @param check [Hash] sensu check definition.
        def validate_check_cron(check)
          must_be_a_string(check[:cron]) ||
            invalid(check, "check cron must be a string")
          begin
            cron_parser = CronParser.new(check[:cron])
            cron_parser.next(Time.now)
          rescue ArgumentError
            invalid(check, "check cron string must use the cron syntax")
          end
        end

        # Validate check scheduling.
        # Validates: publish, interval, standalone, subscribers
        #
        # @param check [Hash] sensu check definition.
        def validate_check_scheduling(check)
          must_be_boolean_if_set(check[:publish]) ||
            invalid(check, "check publish must be boolean")
          unless check[:publish] == false
            if check[:cron]
              validate_check_cron(check)
            else
              (must_be_an_integer(check[:interval]) && check[:interval] > 0) ||
                invalid(check, "check interval must be an integer greater than 0")
            end
          end
          must_be_boolean_if_set(check[:standalone]) ||
            invalid(check, "check standalone must be boolean")
          unless check[:standalone]
            if is_an_array?(check[:subscribers])
              items_must_be_strings(check[:subscribers]) ||
                invalid(check, "check subscribers must each be a string")
            else
              invalid(check, "check subscribers must be an array")
            end
          end
        end

        # Validate check proxy requests.
        # Validates: proxy_requests
        #
        # @param check [Hash] sensu check definition.
        def validate_check_proxy_requests(check)
          if is_a_hash?(check[:proxy_requests])
            must_be_a_hash(check[:proxy_requests][:client_attributes]) ||
              invalid(check, "check proxy_requests client_attributes must be a hash")
          else
            invalid(check, "check proxy_requests must be a hash")
          end
        end

        # Validate check handling.
        # Validates: handler, handlers
        #
        # @param check [Hash] sensu check definition.
        def validate_check_handling(check)
          must_be_a_string_if_set(check[:handler]) ||
            invalid(check, "check handler must be a string")
          must_be_an_array_if_set(check[:handlers]) ||
            invalid(check, "check handlers must be an array")
          if is_an_array?(check[:handlers])
            items_must_be_strings(check[:handlers]) ||
              invalid(check, "check handlers must each be a string")
          end
        end

        # Validate check ttl.
        # Validates: ttl, ttl_status
        #
        # @param check [Hash] sensu check definition.
        def validate_check_ttl(check)
          if is_an_integer?(check[:ttl])
            check[:ttl] > 0 ||
              invalid(check, "check ttl must be greater than 0")
          else
            invalid(check, "check ttl must be an integer")
          end
          must_be_an_integer_if_set(check[:ttl_status]) ||
            invalid(check, "check ttl_status must be an integer")
        end

        # Validate check aggregate.
        # Validates: aggregate
        #
        # @param check [Hash] sensu check definition.
        def validate_check_aggregate(check)
          if check[:aggregates]
            if is_an_array?(check[:aggregates])
              items_must_be_strings(check[:aggregates], /\A[\w\.:|-]+\z/) ||
                invalid(check, "check aggregates items must be strings without spaces or special characters")
            else
              invalid(check, "check aggregates must be an array")
            end
          end
          if check[:aggregate]
            if is_a_string?(check[:aggregate])
              must_match_regex(/\A[\w\.:|-]+\z/, check[:aggregate]) ||
                invalid(check, "check aggregate cannot contain spaces or special characters")
            else
              must_be_boolean(check[:aggregate]) ||
                invalid(check, "check aggregate must be a string (name) or boolean")
            end
          end
        end

        # Validate check flap detection.
        # Validates: low_flap_threshold, high_flap_threshold
        #
        # @param check [Hash] sensu check definition.
        def validate_check_flap_detection(check)
          if either_are_set?(check[:low_flap_threshold], check[:high_flap_threshold])
            must_be_an_integer(check[:low_flap_threshold]) ||
              invalid(check, "check low flap threshold must be an integer")
            must_be_an_integer(check[:high_flap_threshold]) ||
              invalid(check, "check high flap threshold must be an integer")
          end
        end

        # Validate check hook execution.
        # Validates: command, timeout
        #
        # @param check [Hash] sensu check definition.
        # @param hook [Hash] sensu check hook definition.
        def validate_check_hook_execution(check, hook)
          must_be_a_string(hook[:command]) ||
            invalid(check, "check hook command must be a string")
          must_be_a_numeric_if_set(hook[:timeout]) ||
            invalid(check, "check hook timeout must be numeric")
          must_be_boolean_if_set(hook[:stdin]) ||
            invalid(check, "check hook stdin must be boolean")
        end

        # Validate check hooks.
        # Validates: hooks
        #
        # @param check [Hash] sensu check definition.
        def validate_check_hooks(check)
          if check[:hooks].is_a?(Hash)
            check[:hooks].each do |key, hook|
              must_be_either(%w[ok warning critical unknown], key.to_s) ||
                (0..255).map {|i| i.to_s}.include?(key.to_s) ||
                key.to_s == "non-zero" ||
                invalid(check, "check hook key must be a severity, status, or 'non-zero'")
              validate_check_hook_execution(check, hook)
            end
          else
            invalid(check, "check hooks must be a hash")
          end
        end

        # Validate check subdue.
        # Validates: subdue
        #
        # @param check [Hash] sensu check definition.
        def validate_check_subdue(check)
          validate_time_windows(check, "check", :subdue)
        end

        # Validate a Sensu check definition.
        #
        # @param check [Hash] sensu check definition.
        def validate_check(check)
          validate_check_name(check)
          validate_check_execution(check)
          validate_check_source(check) if check[:source]
          validate_check_scheduling(check)
          validate_check_proxy_requests(check) if check[:proxy_requests]
          validate_check_handling(check)
          validate_check_ttl(check) if check[:ttl]
          validate_check_aggregate(check)
          validate_check_flap_detection(check)
          validate_check_hooks(check) if check[:hooks]
          validate_check_subdue(check) if check[:subdue]
        end
      end
    end
  end
end
