require "sensu/settings/validators/subdue"
require "sensu/settings/validators/check"
require "sensu/settings/validators/filter"

module Sensu
  module Settings
    module Validators
      include Subdue
      include Check
      include Filter
    end
  end
end
