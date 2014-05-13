require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings"

describe "Sensu::Settings" do
  include Helpers

  it "can provide a loader" do
    Sensu::Settings.should respond_to(:load)
    Sensu::Settings.load.should be_an_instance_of(Sensu::Settings::Loader)
    settings = Sensu::Settings.load
    settings.should respond_to(:validate!)
  end
end
