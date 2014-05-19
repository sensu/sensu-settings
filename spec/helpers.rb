require "rspec"
require "codeclimate-test-reporter"

unless RUBY_VERSION < "1.9" || RUBY_PLATFORM =~ /java/
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

module Helpers; end
