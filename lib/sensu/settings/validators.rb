require "sensu/settings/validators/subdue"
require "sensu/settings/validators/check"

module Sensu
  module Settings
    module Validators
      include Subdue
      include Check
    end
  end
end
