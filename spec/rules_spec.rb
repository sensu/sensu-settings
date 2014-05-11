require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings/rules"

describe "Sensu::Settings::Rules" do
  include Helpers
  include Sensu::Settings::Rules

  it "can validate value types" do
    must_be_a_hash({}).should be_true
    must_be_a_hash("").should be_false
    must_be_an_array([]).should be_true
    must_be_an_array("").should be_false
    must_be_a_string("").should be_true
    must_be_a_string(1).should be_false
    must_be_an_integer(1).should be_true
    must_be_an_integer("").should be_false
    must_be_a_numeric(1.5).should be_true
    must_be_a_numeric("").should be_false
    must_match_regex(/^foo$/, "foo").should be_true
    must_match_regex(/^foo$/, "bar").should be_false
  end
end
