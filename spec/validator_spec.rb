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
    reasons.size.should eq(4)
  end

  it "can validate an empty check definition" do
    @validator.validate_check({})
    reasons = @validator.failures.map do |failure|
      failure[:message]
    end
    reasons.should include("check name must be a string")
    reasons.should include("check name cannot contain spaces or special characters")
    reasons.should include("check command must be a string")
    reasons.should include("check interval must be an integer")
    reasons.should include("check subscribers must be an array")
    reasons.size.should eq(5)
  end

  it "can validate a check definition" do
    check = {:name => "foo bar"}
    @validator.validate_check(check)
    @validator.failures.size.should eq(4)
    @validator.reset!
    check[:name] = "foo"
    @validator.validate_check(check)
    @validator.failures.size.should eq(3)
    @validator.reset!
    check[:command] = 1
    @validator.validate_check(check)
    @validator.failures.size.should eq(3)
    @validator.reset!
    check[:command] = "true"
    @validator.validate_check(check)
    @validator.failures.size.should eq(2)
    @validator.reset!
    check[:interval] = "1"
    @validator.validate_check(check)
    @validator.failures.size.should eq(2)
    @validator.reset!
    check[:interval] = 1
    @validator.validate_check(check)
    @validator.failures.size.should eq(1)
    @validator.reset!
    check[:subscribers] = 1
    @validator.validate_check(check)
    @validator.failures.size.should eq(1)
    @validator.reset!
    check[:subscribers] = []
    @validator.validate_check(check)
    @validator.failures.size.should eq(0)
    @validator.reset!
    check[:standalone] = "true"
    @validator.validate_check(check)
    @validator.failures.size.should eq(1)
    @validator.reset!
    check[:standalone] = true
    @validator.validate_check(check)
    @validator.failures.size.should eq(0)
    @validator.reset!
    check[:handler] = 1
    @validator.validate_check(check)
    @validator.failures.size.should eq(1)
    @validator.reset!
    check[:handler] = "cat"
    @validator.validate_check(check)
    @validator.failures.size.should eq(0)
    @validator.reset!
    check[:handlers] = "cat"
    @validator.validate_check(check)
    @validator.failures.size.should eq(1)
    @validator.reset!
    check[:handlers] = ["cat"]
    @validator.validate_check(check)
    @validator.failures.size.should eq(0)
    @validator.reset!
    check[:low_flap_threshold] = "25"
    @validator.validate_check(check)
    @validator.failures.size.should eq(2)
    @validator.reset!
    check[:low_flap_threshold] = 25
    @validator.validate_check(check)
    @validator.failures.size.should eq(1)
    @validator.reset!
    check[:high_flap_threshold] = "55"
    @validator.validate_check(check)
    @validator.failures.size.should eq(1)
    @validator.reset!
    check[:high_flap_threshold] = 55
    @validator.validate_check(check)
    @validator.failures.size.should eq(0)
    @validator.reset!
  end
end
