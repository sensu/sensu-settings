require "sensu/settings/loader"

module Sensu
  module Settings
    # Load Sensu settings.
    #
    # @param [Hash] options
    # @option options [String] :config_file to load.
    # @option options [String] :config_dir to load.
    # @option options [String] :config_dirs to load.
    # @return [Loader] a loaded instance of Loader.
    def self.load(options={})
      loader = Loader.new
      loader.load_env
      if options[:config_file]
        loader.load_file(options[:config_file])
      end
      if options[:config_dir]
        loader.load_directory(options[:config_dir])
      end
      if options[:config_dirs]
        options[:config_dirs].each do |directory|
          loader.load_directory(directory)
        end
      end
      loader.set_env!
      loader
    end
  end
end
