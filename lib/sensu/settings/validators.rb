require "sensu/settings/validators/subdue"
require "sensu/settings/validators/check"
require "sensu/settings/validators/filter"
require "sensu/settings/validators/mutator"
require "sensu/settings/validators/handler"

module Sensu
  module Settings
    module Validators
      include Subdue
      include Check
      include Filter
      include Mutator
      include Handler
    end
  end
end
