require "sensu/settings/loader"

module Sensu
  module Settings
    # Load Sensu settings.
    #
    # @param options [Hash]
    # @return [Loader] a loaded instance of Loader.
    def self.load(options={})
      loader = Loader.new
      loader.load(options)
      loader
    end
  end
end
