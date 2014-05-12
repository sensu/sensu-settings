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
    @validator.reset.should eq(4)
    check[:name] = "foo"
    @validator.validate_check(check)
    @validator.reset.should eq(3)
    check[:command] = 1
    @validator.validate_check(check)
    @validator.reset.should eq(3)
    check[:command] = "true"
    @validator.validate_check(check)
    @validator.reset.should eq(2)
    check[:interval] = "1"
    @validator.validate_check(check)
    @validator.reset.should eq(2)
    check[:interval] = 1
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subscribers] = 1
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subscribers] = [1]
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subscribers] = []
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:standalone] = "true"
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:standalone] = true
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:handler] = 1
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:handler] = "cat"
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:handlers] = "cat"
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:handlers] = ["cat"]
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:low_flap_threshold] = "25"
    @validator.validate_check(check)
    @validator.reset.should eq(2)
    check[:low_flap_threshold] = 25
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:high_flap_threshold] = "55"
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:high_flap_threshold] = 55
    @validator.validate_check(check)
    @validator.reset.should eq(0)
  end

  it "can validate check subdue" do
    check = {
      :name => "foo",
      :command => "true",
      :interval => 1,
      :standalone => true
    }
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:subdue] = true
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue] = {
      :at => "unknown"
    }
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:at] = "publisher"
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:subdue][:at] = "handler"
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:subdue][:begin] = "14:30"
    check[:subdue][:end] = 1
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:begin] = 1
    check[:subdue][:end] = "14:30"
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:begin] = "14:30"
    check[:subdue][:end] = "16:30"
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:subdue][:days] = 1
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:days] = ["unknown"]
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:days] = [true]
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:days] = ["monday"]
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:subdue][:exceptions] = 1
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:exceptions] = []
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:subdue][:exceptions] = [1]
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:exceptions] = [{}]
    @validator.validate_check(check)
    @validator.reset.should eq(0)
    check[:subdue][:exceptions] = [{:begin => "15:00"}]
    @validator.validate_check(check)
    @validator.reset.should eq(1)
    check[:subdue][:exceptions] = [{:begin => "15:00", :end => "15:30"}]
    @validator.validate_check(check)
    @validator.reset.should eq(0)
  end
end
