require "sensu/settings/validators/sensu"
require "sensu/settings/validators/transport"
require "sensu/settings/validators/subdue"
require "sensu/settings/validators/check"
require "sensu/settings/validators/filter"
require "sensu/settings/validators/mutator"
require "sensu/settings/validators/handler"
require "sensu/settings/validators/client"
require "sensu/settings/validators/api"

module Sensu
  module Settings
    module Validators
      include Sensu
      include Transport
      include Subdue
      include Check
      include Filter
      include Mutator
      include Handler
      include Client
      include API
    end
  end
end
