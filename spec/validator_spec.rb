require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings/validator"

describe "Sensu::Settings::Validator" do
  include Helpers

  before do
    @validator = Sensu::Settings::Validator.new
  end

  it "can run, validating setting categories" do
    failures = @validator.run({})
    failures.each do |failure|
      failure[:object].should be_nil
    end
    reasons = failures.map do |failure|
      failure[:message]
    end
    reasons.should include("checks must be a hash")
    reasons.should include("filters must be a hash")
    reasons.should include("mutators must be a hash")
    reasons.should include("handlers must be a hash")
  end

  it "can validate an empty check definition" do
    @validator.validate_check({})
    reasons = @validator.failures.map do |failure|
      failure[:message]
    end
    reasons.should include("check name must be a string")
    reasons.should include("check name cannot contain spaces or special characters")
    reasons.should include("check command must be a string")
    reasons.should include("check is missing interval")
  end
end
