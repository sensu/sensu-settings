require "sensu/settings/key_value"
require "sensu/settings/validator"
require "sensu/json"
require "tmpdir"
require "socket"
require "digest"

module Sensu
  module Settings
    class Loader
      class Error < RuntimeError; end

      # @!attribute [r] warnings
      #   @return [Array] loader warnings.
      attr_reader :warnings

      # @!attribute [r] errors
      #   @return [Array] loader errors.
      attr_reader :errors

      # @!attribute [r] loaded_files
      #   @return [Array] loaded config files.
      attr_reader :loaded_files

      def initialize
        @warnings = []
        @errors = []
        @settings = default_settings
        @indifferent_access = false
        @loaded_files = []
        self.class.create_category_methods
      end

      # Auto-detected defaults for client definition
      #
      # Client name defaults to system hostname.
      # Client address defaults to first detected non-loopback ipv4 address.
      #
      # Client subscriptions are intentionally omitted here as sensu-client
      # will provide defaults using client name after final settings are
      # loaded.
      #
      # @return [Hash] default client settings
      def client_defaults
        {
          :name => system_hostname,
          :address => system_address
        }
      end

      # Default settings.
      #
      # @return [Hash] settings.
      def default_settings
        default = {
          :client => {},
          :sensu => {
            :spawn => {
              :limit => 12
            },
            :keepalives => {
              :thresholds => {
                :warning => 120,
                :critical => 180
              }
            }
          },
          :transport => {
            :name => "rabbitmq",
            :reconnect_on_error => true
          }
        }
        CATEGORIES.each do |category|
          default[category] = {}
        end
        if ["client", "rspec"].include?(sensu_service_name)
          default[:client] = client_defaults
        end
        default
      end

      # Create setting category accessors and methods to test the
      # existence of definitions. Called in initialize().
      def self.create_category_methods
        CATEGORIES.each do |category|
          define_method(category) do
            setting_category(category)
          end
          method_name = category.to_s.chop + "_exists?"
          define_method(method_name.to_sym) do |name|
            definition_exists?(category, name)
          end
        end
      end

      # Access settings as an indifferent hash.
      #
      # @return [Hash] settings.
      def to_hash
        unless @indifferent_access
          indifferent_access!
          @hexdigest = nil
        end
        @settings
      end

      # Retrieve the setting object corresponding to a key, acting
      # like a Hash object.
      #
      # @param key [String, Symbol]
      # @return [Object] value for key.
      def [](key)
        to_hash[key]
      end

      # Create a SHA256 hex digest for the settings Hash object. The
      # client definition scope is ignored when the current process is
      # not a Sensu client, as it is essentially ignored and it will
      # likely cause a sum mismatch between two Sensu service systems.
      # This method will not recalculate the hex digest, unless the
      # settings have been altered, determine by the values of
      # `@hexdigest` and `@indifferent_access`.
      #
      # @return [String] SHA256 hex digest.
      def hexdigest
        if @hexdigest && @indifferent_access
          @hexdigest
        else
          hash = case sensu_service_name
          when "client", "rspec"
            to_hash
          else
            to_hash.reject do |key, value|
              key.to_s == "client"
            end
          end
          @hexdigest = Digest::SHA256.hexdigest(hash.to_s)
        end
      end

      # Load settings from remote key-value store
      #
      # @param [String] key-value type
      # @param [String] key-value url
      # @param [String] key-value configuration root path
      # @param [String] key-value authentication token (string) or options json-serialized
      def load_kv(kv_type, url, chroot="/", auth=nil)
        Sensu::Settings::KeyValue.type   ||= kv_type
        Sensu::Settings::KeyValue.url    ||= url
        Sensu::Settings::KeyValue.chroot ||= chroot
        Sensu::Settings::KeyValue.auth   ||= auth

        begin
          merged = deep_merge(@settings, Sensu::Settings::KeyValue.read || {})
          changes = deep_diff(@settings, merged)
          if changes.keys.count > 0
            warning("config from #{Sensu::Settings::KeyValue.type} key-value #{Sensu::Settings::KeyValue.url} at chroot #{Sensu::Settings::KeyValue.chroot} applied changes", {
              :changes => changes
            })
          end
          @settings = merged
          @indifferent_access = false
        rescue Sensu::JSON::ParseError => error
          load_error("config from key-value store must be valid json", {
            :url => url,
            :chroot => chroot,
            :type => kv_type,
          })
        end
      end

      # Load settings from the environment.
      #
      # Loads: SENSU_TRANSPORT_NAME, RABBITMQ_URL, REDIS_URL,
      #        SENSU_CLIENT_NAME, SENSU_CLIENT_ADDRESS
      #        SENSU_CLIENT_SUBSCRIPTIONS, SENSU_API_PORT
      def load_env
        load_transport_env
        load_rabbitmq_env
        load_redis_env
        load_client_env
        load_api_env
      end

      # Load settings from a JSON file.
      #
      # @param [String] file path.
      # @param must_exist [TrueClass, FalseClass] if the file must
      #   exist and is readable.
      def load_file(file, must_exist=true)
        if File.file?(file) && File.readable?(file)
          begin
            warning("loading config file", :file => file)
            contents = read_config_file(file)
            config = contents.empty? ? {} : Sensu::JSON.load(contents)
            merged = deep_merge(@settings, config)
            unless @loaded_files.empty?
              changes = deep_diff(@settings, merged)
              warning("config file applied changes", {
                :file => file,
                :changes => changes
              })
            end
            @settings = merged
            @indifferent_access = false
            @loaded_files << file
          rescue Sensu::JSON::ParseError => error
            load_error("config file must be valid json", {
              :file => file,
              :error => error.to_s
            })
          end
        elsif must_exist
          load_error("config file does not exist or is not readable", :file => file)
        else
          warning("config file does not exist or is not readable", :file => file)
          warning("ignoring config file", :file => file)
        end
      end

      # Load settings from files in a directory. Files may be in
      # nested directories.
      #
      # @param [String] directory path.
      def load_directory(directory)
        warning("loading config files from directory", :directory => directory)
        path = directory.gsub(/\\(?=\S)/, "/")
        if File.readable?(path) && File.executable?(path)
          Dir.glob(File.join(path, "**{,/*/**}/*.json")).uniq.each do |file|
            load_file(file)
          end
        else
          load_error("insufficient permissions for loading", :directory => directory)
        end
      end

      # Load Sensu client settings overrides. This method adds any overrides to
      # the client definition. Overrides include:
      #
      # * Ensuring client subscriptions include a single subscription based on the
      # client name, e.g "client:i-424242".
      def load_client_overrides
        @settings[:client][:subscriptions] ||= []
        if @settings[:client][:subscriptions].is_a?(Array)
          @settings[:client][:subscriptions] << "client:#{@settings[:client][:name]}"
          @settings[:client][:subscriptions].uniq!
          warning("applied sensu client overrides", :client => @settings[:client])
          @indifferent_access = false
        else
          warning("unable to apply sensu client overrides", {
            :reason => "client subscriptions is not an array",
            :client => @settings[:client]
          })
        end
      end

      # Load overrides, i.e. settings which should always be present.
      # Examples include client settings overrides which ensure a per-client subscription.
      def load_overrides!
        load_client_overrides if ["client", "rspec"].include?(sensu_service_name)
      end

      # Set Sensu settings related environment variables. This method
      # sets `SENSU_LOADED_TEMPFILE` to a new temporary file path,
      # a file containing the colon delimited list of loaded
      # configuration files (using `create_loaded_tempfile!()`. The
      # environment variable `SENSU_CONFIG_FILES` has been removed,
      # due to the exec ARG_MAX (E2BIG) error when spawning processes
      # after loading many configuration files (e.g. > 2000).
      def set_env!
        ENV["SENSU_LOADED_TEMPFILE"] = create_loaded_tempfile!
      end

      # Validate the loaded settings.
      #
      # @return [Array] validation failures.
      def validate
        validator = Validator.new
        @errors += validator.run(@settings, sensu_service_name)
      end

      private

      # Retrieve setting category definitions.
      #
      # @param [Symbol] category to retrive.
      # @return [Array<Hash>] category definitions.
      def setting_category(category)
        @settings[category].map do |name, details|
          details.merge(:name => name.to_s)
        end
      end

      # Check to see if a definition exists in a category.
      #
      # @param [Symbol] category to inspect for the definition.
      # @param [String] name of definition.
      # @return [TrueClass, FalseClass]
      def definition_exists?(category, name)
        @settings[category].has_key?(name.to_sym)
      end

      # Creates an indifferent hash.
      #
      # @return [Hash] indifferent hash.
      def indifferent_hash
        Hash.new do |hash, key|
          if key.is_a?(String)
            hash[key.to_sym]
          end
        end
      end

      # Create a copy of a hash with indifferent access.
      #
      # @param hash [Hash] hash to make indifferent.
      # @return [Hash] indifferent version of hash.
      def with_indifferent_access(hash)
        hash = indifferent_hash.merge(hash)
        hash.each do |key, value|
          if value.is_a?(Hash)
            hash[key] = with_indifferent_access(value)
          end
        end
      end

      # Update settings to have indifferent access.
      def indifferent_access!
        @settings = with_indifferent_access(@settings)
        @indifferent_access = true
      end

      # Load Sensu transport settings from the environment. This
      # method sets the Sensu transport name to `SENSU_TRANSPORT_NAME`
      # if set.
      def load_transport_env
        if ENV["SENSU_TRANSPORT_NAME"]
          @settings[:transport][:name] = ENV["SENSU_TRANSPORT_NAME"]
          warning("using sensu transport name environment variable", :transport => @settings[:transport])
          @indifferent_access = false
        end
      end

      # Load Sensu RabbitMQ settings from the environment. This method
      # sets the RabbitMQ settings to `RABBITMQ_URL` if set. The Sensu
      # RabbitMQ transport accepts a URL string for options.
      def load_rabbitmq_env
        if ENV["RABBITMQ_URL"]
          @settings[:rabbitmq] = ENV["RABBITMQ_URL"]
          warning("using rabbitmq url environment variable", :rabbitmq => @settings[:rabbitmq])
          @indifferent_access = false
        end
      end

      # Load Sensu Redis settings from the environment.
      #
      # This method evaluates the REDIS_SENTINEL_URLS and REDIS_URL environment variables
      # and configures the Redis settings accordingly.
      #
      # When REDIS_SENTINEL_URLS is provided as a list of one or more
      # comma-separated URLs, e.g.
      # "redis://10.0.0.1:26379,redis://10.0.0.2:26379" these URLs will take
      # precedence over the value provided by REDIS_URL, if any.
      #
      # As the redis library accepts a URL string for options. This
      # configuration applies to data storage and the redis transport, if used.
      def load_redis_env
        if ENV["REDIS_SENTINEL_URLS"]
          @settings[:redis] = {:sentinels => ENV["REDIS_SENTINEL_URLS"]}
          warning("using redis sentinel url environment variable", :sentinels => @settings[:redis][:sentinels])
          @indifferent_access = false
        elsif ENV["REDIS_URL"]
          @settings[:redis] = ENV["REDIS_URL"]
          warning("using redis url environment variable", :redis => @settings[:redis])
          @indifferent_access = false
        end
      end

      # Load Sensu client settings from the environment. This method
      # loads client settings from several variables:
      # `SENSU_CLIENT_NAME`, `SENSU_CLIENT_ADDRESS`, and
      # `SENSU_CLIENT_SUBSCRIPTIONS`.
      def load_client_env
        @settings[:client][:name] = ENV["SENSU_CLIENT_NAME"] if ENV["SENSU_CLIENT_NAME"]
        @settings[:client][:address] = ENV["SENSU_CLIENT_ADDRESS"] if ENV["SENSU_CLIENT_ADDRESS"]
        @settings[:client][:subscriptions] = ENV["SENSU_CLIENT_SUBSCRIPTIONS"].split(",") if ENV["SENSU_CLIENT_SUBSCRIPTIONS"]
        if ENV.keys.any? {|k| k =~ /^SENSU_CLIENT/}
          warning("using sensu client environment variables", :client => @settings[:client])
        end
        @indifferent_access = false
      end

      # Load Sensu API settings from the environment. This method sets
      # the API port to `SENSU_API_PORT` if set.
      def load_api_env
        if ENV["SENSU_API_PORT"]
          @settings[:api] ||= {}
          @settings[:api][:port] = ENV["SENSU_API_PORT"].to_i
          warning("using api port environment variable", :api => @settings[:api])
          @indifferent_access = false
        end
      end

      # Read a configuration file and force its encoding to 8-bit
      # ASCII, ignoring invalid characters. If there is a UTF-8 BOM,
      # it will be removed. Some JSON parsers force ASCII but do not
      # remove the UTF-8 BOM if present, causing encoding conversion
      # errors. This method is for consistency across Sensu::JSON
      # adapters and system platforms.
      #
      # @param [String] file path to read.
      # @return [String] file contents.
      def read_config_file(file)
        contents = IO.read(file)
        if contents.respond_to?(:force_encoding)
          encoding = ::Encoding::ASCII_8BIT
          contents = contents.force_encoding(encoding)
          contents.sub!("\xEF\xBB\xBF".force_encoding(encoding), "")
        else
          contents.sub!(/^\357\273\277/, "")
        end
        contents.strip
      end

      # Deep merge two hashes.
      #
      # @param [Hash] hash_one to serve as base.
      # @param [Hash] hash_two to merge in.
      # @return [Hash] deep merged hash.
      def deep_merge(hash_one, hash_two)
        merged = hash_one.dup
        hash_two.each do |key, value|
          merged[key] = case
          when hash_one[key].is_a?(Hash) && value.is_a?(Hash)
            deep_merge(hash_one[key], value)
          when hash_one[key].is_a?(Array) && value.is_a?(Array)
            hash_one[key].concat(value).uniq
          else
            value
          end
        end
        merged
      end

      # Compare two hashes.
      #
      # @param [Hash] hash_one to compare.
      # @param [Hash] hash_two to compare.
      # @return [Hash] comparison diff hash.
      def deep_diff(hash_one, hash_two)
        keys = hash_one.keys.concat(hash_two.keys).uniq
        keys.inject(Hash.new) do |diff, key|
          unless hash_one[key] == hash_two[key]
            if hash_one[key].is_a?(Hash) && hash_two[key].is_a?(Hash)
              diff[key] = deep_diff(hash_one[key], hash_two[key])
            else
              diff[key] = [hash_one[key], hash_two[key]]
            end
          end
          diff
        end
      end

      # Create a temporary file containing the colon delimited list of
      # loaded configuration files. Ruby TempFile is not used to
      # create the temporary file as it would be removed if the Sensu
      # service daemonizes (fork/detach). The file is created in the
      # system temporary file directory for the platform (Linux,
      # Windows, etc.) and the file name contains the Sensu service
      # name to reduce the likelihood of one Sensu service affecting
      # another.
      #
      # @return [String] tempfile path.
      def create_loaded_tempfile!
        dir = ENV["SENSU_LOADED_TEMPFILE_DIR"] || Dir.tmpdir
        file_name = "sensu_#{sensu_service_name}_loaded_files"
        path = File.join(dir, file_name)
        File.open(path, "w") do |file|
          file.write(@loaded_files.join(":"))
        end
        path
      end

      # Retrieve Sensu service name.
      #
      # @return [String] service name.
      def sensu_service_name
        File.basename($0).split("-").last
      end

      # Retrieve the system hostname. If the hostname cannot be
      # determined and an error is thrown, return "unknown", the same
      # value Sensu uses for JIT clients.
      #
      # @return [String] system hostname.
      def system_hostname
        Socket.gethostname rescue "unknown"
      end

      # Retrieve the system IP address. If a valid non-loopback
      # IPv4 address cannot be found and an error is thrown,
      # "unknown" will be returned.
      #
      # @return [String] system ip address
      def system_address
        Socket.ip_address_list.find { |address|
          address.ipv4? && !address.ipv4_loopback?
        }.ip_address rescue "unknown"
      end

      # Record a warning.
      #
      # @param message [String] warning message.
      # @param data [Hash] warning context.
      # @return [Array] current warnings.
      def warning(message, data={})
        @warnings << {
          :message => message
        }.merge(data)
      end

      # Record a load error and raise a load error exception.
      #
      # @param message [String] load error message.
      # @param data [Hash] load error context.
      def load_error(message, data={})
        @errors << {
          :message => message
        }.merge(data)
        raise(Error, message)
      end
    end
  end
end
