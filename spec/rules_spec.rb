require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings/rules"

describe "Sensu::Settings::Rules" do
  include Helpers
  include Sensu::Settings::Rules

  it "can provide validation rules" do
    must_be_a_hash({}).should be_true
    must_be_a_hash("").should be_false
    must_be_a_hash_if_set({}).should be_true
    must_be_a_hash_if_set(nil).should be_true
    must_be_a_hash_if_set("").should be_false
    must_be_an_array([]).should be_true
    must_be_an_array("").should be_false
    must_be_an_array_if_set([]).should be_true
    must_be_an_array_if_set(nil).should be_true
    must_be_an_array_if_set("").should be_false
    must_be_a_string("").should be_true
    must_be_a_string(1).should be_false
    must_be_a_string_if_set("").should be_true
    must_be_a_string_if_set(nil).should be_true
    must_be_a_string_if_set(1).should be_false
    must_be_an_integer(1).should be_true
    must_be_an_integer("").should be_false
    must_be_a_numeric(1.5).should be_true
    must_be_a_numeric("").should be_false
    must_match_regex(/^foo$/, "foo").should be_true
    must_match_regex(/^foo$/, "bar").should be_false
    must_be_boolean_if_set(true).should be_true
    must_be_boolean_if_set(false).should be_true
    must_be_boolean_if_set(nil).should be_true
    must_be_boolean_if_set("").should be_false
    items_must_be_strings([]).should be_true
    items_must_be_strings(["test"]).should be_true
    items_must_be_strings([1]).should be_false
    items_must_be_strings([""]).should be_false
    either_are_set?(1).should be_true
    either_are_set?(1, nil).should be_true
    either_are_set?(nil, nil, 1).should be_true
    either_are_set?(1, 1).should be_true
    either_are_set?.should be_false
    either_are_set?(nil).should be_false
    either_are_set?(nil, nil).should be_false
    must_be_time("16:30").should be_true
    must_be_time("16:30", "21:00").should be_true
    must_be_time(false).should be_false
    must_be_time(false, "21:00").should be_false
    unless RUBY_VERSION < "1.9"
      must_be_time("false").should be_false
      must_be_time("false", "21:00").should be_false
    end
    must_be_time(1).should be_false
    must_be_either(%w[foo bar], "foo").should be_true
    must_be_either(%w[foo bar], "bar").should be_true
    must_be_either(%w[foo bar], ["foo", "bar"]).should be_true
    must_be_either(%w[foo bar], "baz").should be_false
    must_be_either(%w[foo bar], 1).should be_false
    must_be_either(%w[foo bar], nil).should be_false
    must_be_either(%w[foo bar], ["foo", nil]).should be_false
    must_be_either_if_set(%w[foo bar], "foo").should be_true
    must_be_either_if_set(%w[foo bar], nil).should be_true
    must_be_either_if_set(%w[foo bar], "baz").should be_false
  end
end
