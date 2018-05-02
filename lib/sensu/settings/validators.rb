require "sensu/settings/validators/sensu"
require "sensu/settings/validators/tessen"
require "sensu/settings/validators/transport"
require "sensu/settings/validators/time_window"
require "sensu/settings/validators/check"
require "sensu/settings/validators/filter"
require "sensu/settings/validators/mutator"
require "sensu/settings/validators/handler"
require "sensu/settings/validators/client"
require "sensu/settings/validators/api"
require "sensu/settings/validators/extension"

module Sensu
  module Settings
    module Validators
      include Sensu
      include Tessen
      include Transport
      include TimeWindow
      include Check
      include Filter
      include Mutator
      include Handler
      include Client
      include API
      include Extension
    end
  end
end
