require "sensu/settings/validators/subdue"
require "sensu/settings/validators/check"
require "sensu/settings/validators/filter"
require "sensu/settings/validators/mutator"

module Sensu
  module Settings
    module Validators
      include Subdue
      include Check
      include Filter
      include Mutator
    end
  end
end
