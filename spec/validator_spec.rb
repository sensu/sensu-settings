require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings/validator"

describe "Sensu::Settings::Validator" do
  include Helpers

  before do
    @validator = Sensu::Settings::Validator.new
  end

  it "can run, validating setting categories" do
    failures = @validator.run({})
    expect(failures).to be_kind_of(Array)
    failures.each do |failure|
      expect(failure[:object]).to be(nil)
    end
    reasons = failures.map do |failure|
      failure[:message]
    end
    expect(reasons).to include("checks must be a hash")
    expect(reasons).to include("filters must be a hash")
    expect(reasons).to include("mutators must be a hash")
    expect(reasons).to include("handlers must be a hash")
    expect(reasons.size).to eq(5)
  end

  it "can validate a transport definition" do
    transport = nil
    @validator.validate_transport(transport)
    expect(@validator.reset).to eq(1)
    transport = {}
    @validator.validate_transport(transport)
    expect(@validator.reset).to eq(0)
    transport[:name] = 1
    @validator.validate_transport(transport)
    expect(@validator.reset).to eq(1)
    transport[:name] = "rabbitmq"
    @validator.validate_transport(transport)
    expect(@validator.reset).to eq(0)
  end

  it "can run, validating transport" do
    settings = {
      :transport => {
        :name => 1
      }
    }
    @validator.run(settings)
    expect(@validator.reset).to eq(5)
    settings[:transport][:name] = "rabbitmq"
    @validator.run(settings)
    expect(@validator.reset).to eq(4)
  end

  it "can validate an empty check definition" do
    @validator.validate_check({})
    reasons = @validator.failures.map do |failure|
      failure[:message]
    end
    expect(reasons).to include("check name cannot contain spaces or special characters")
    expect(reasons).to include("either check command or extension must be set")
    expect(reasons).to include("check interval must be an integer")
    expect(reasons).to include("check subscribers must be an array")
    expect(reasons.size).to eq(5)
  end

  it "can validate a check definition" do
    check = {:name => "foo bar"}
    @validator.validate_check(check)
    expect(@validator.reset).to eq(4)
    check[:name] = "foo"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(3)
    check[:command] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(3)
    check[:command] = "true"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(2)
    check[:timeout] = "foo"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(3)
    check[:timeout] = 1.5
    @validator.validate_check(check)
    expect(@validator.reset).to eq(2)
    check[:timeout] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(2)
    check[:publish] = "false"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(3)
    check[:publish] = false
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:publish] = true
    @validator.validate_check(check)
    expect(@validator.reset).to eq(2)
    check[:interval] = "1"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(2)
    check[:interval] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subscribers] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subscribers] = [1]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subscribers] = []
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:standalone] = "true"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:standalone] = true
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:handler] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:handler] = "cat"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:handlers] = "cat"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:handlers] = ["cat"]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:low_flap_threshold] = "25"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(2)
    check[:low_flap_threshold] = 25
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:high_flap_threshold] = "55"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:high_flap_threshold] = 55
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:source] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:source] = "switch-%42%"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:extension] = 'foo'
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check.delete(:command)
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:extension] = true
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
  end

  it "can validate check subdue" do
    check = {
      :name => "foo",
      :command => "true",
      :interval => 1,
      :standalone => true
    }
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:subdue] = true
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue] = {
      :at => "unknown"
    }
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:at] = "publisher"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:subdue][:at] = "handler"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:subdue][:begin] = "14:30"
    check[:subdue][:end] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:begin] = 1
    check[:subdue][:end] = "14:30"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:begin] = "14:30"
    check[:subdue][:end] = "16:30"
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:subdue][:days] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:days] = ["unknown"]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:days] = [true]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:days] = ["monday"]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:subdue][:exceptions] = 1
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:exceptions] = []
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:subdue][:exceptions] = [1]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:exceptions] = [{}]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
    check[:subdue][:exceptions] = [{:begin => "15:00"}]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(1)
    check[:subdue][:exceptions] = [{:begin => "15:00", :end => "15:30"}]
    @validator.validate_check(check)
    expect(@validator.reset).to eq(0)
  end

  it "can run, validating checks" do
    settings = {
      :checks => {
        :foo => {
          :command => "true",
          :standalone => true
        }
      }
    }
    @validator.run(settings)
    expect(@validator.reset).to eq(5)
    settings[:checks][:foo][:interval] = 1
    @validator.run(settings)
    expect(@validator.reset).to eq(4)
  end

  it "can validate a filter definition" do
    filter = {}
    @validator.validate_filter(filter)
    expect(@validator.reset).to eq(1)
    filter[:attributes] = 1
    @validator.validate_filter(filter)
    expect(@validator.reset).to eq(1)
    filter[:attributes] = {}
    @validator.validate_filter(filter)
    expect(@validator.reset).to eq(0)
    filter[:negate] = "true"
    @validator.validate_filter(filter)
    expect(@validator.reset).to eq(1)
    filter[:negate] = true
    @validator.validate_filter(filter)
    expect(@validator.reset).to eq(0)
  end

  it "can validate a mutator definition" do
    mutator = {}
    @validator.validate_mutator(mutator)
    expect(@validator.reset).to eq(1)
    mutator[:command] = "cat"
    @validator.validate_mutator(mutator)
    expect(@validator.reset).to eq(0)
    mutator[:timeout] = "foo"
    @validator.validate_mutator(mutator)
    expect(@validator.reset).to eq(1)
    mutator[:timeout] = 1.5
    @validator.validate_mutator(mutator)
    expect(@validator.reset).to eq(0)
    mutator[:timeout] = 1
    @validator.validate_mutator(mutator)
    expect(@validator.reset).to eq(0)
  end

  it "can validate a handler definition" do
    handler = {}
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(2)
    handler[:type] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(2)
    handler[:type] = "unknown"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:type] = "pipe"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:command] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:command] = "cat"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:timeout] = "foo"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:timeout] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:mutator] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:mutator] = "foo"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:handle_flapping] = "true"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:handle_flapping] = true
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:handle_flapping] = false
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:filter] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:filter] = "foo"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:filters] = "foo"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:filters] = []
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:filters] = [1]
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:filters] = ["foo"]
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:severities] = "foo"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:severities] = []
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:severities] = ["foo"]
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:severities] = ["warning", "unknown"]
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
  end

  it "can validate a tcp/udp handler definition" do
    handler = {
      :type => "tcp"
    }
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:socket] = {}
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(2)
    handler[:socket][:host] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(2)
    handler[:socket][:host] = "127.0.0.1"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:socket][:port] = "foo"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:socket][:port] = 2003
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
  end

  it "can validate a transport handler definition" do
    handler = {
      :type => "transport"
    }
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:pipe] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:pipe] = {}
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(3)
    handler[:pipe][:type] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(3)
    handler[:pipe][:type] = "unknown"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(2)
    handler[:pipe][:type] = "direct"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:pipe][:name] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:pipe][:name] = "foo"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:pipe][:options] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:pipe][:options] = {}
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
  end

  it "can validate a handler set definition" do
    handler = {
      :type => "set"
    }
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:handlers] = 1
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:handlers] = "default"
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:handlers] = [1]
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:handlers] = ["default"]
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
  end

  it "can validate handler subdue" do
    handler = {
      :name => "foo",
      :type => "pipe",
      :command => "cat"
    }
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
    handler[:subdue] = true
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(1)
    handler[:subdue] = {
      :at => "handler",
      :begin => "14:30",
      :end => "15:45"
    }
    @validator.validate_handler(handler)
    expect(@validator.reset).to eq(0)
  end

  it "can validate a client definition" do
    client = true
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client = {}
    @validator.validate_client(client)
    expect(@validator.reset).to eq(4)
    client[:name] = 1
    @validator.validate_client(client)
    expect(@validator.reset).to eq(4)
    client[:name] = "foo bar"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(3)
    client[:name] = "foo"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(2)
    client[:address] = 1
    @validator.validate_client(client)
    expect(@validator.reset).to eq(2)
    client[:address] = "127.0.0.1"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:subscriptions] = true
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:subscriptions] = []
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:subscriptions] = [1]
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:subscriptions] = ["bar"]
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:redact] = true
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:redact] = []
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:redact] = [1]
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:redact] = ["secret"]
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:safe_mode] = 1
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:safe_mode] = false
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
  end

  it "can validate client socket" do
    client = {
      :name => "foo",
      :address => "127.0.0.1",
      :subscriptions => ["bar"]
    }
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:socket] = true
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:socket] = {}
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:socket][:bind] = true
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:socket][:bind] = "127.0.0.1"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:socket][:port] = "2012"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:socket][:port] = 2012
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
  end

  it "can validate client keepalive" do
    client = {
      :name => "foo",
      :address => "127.0.0.1",
      :subscriptions => ["bar"]
    }
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:keepalive] = true
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:keepalive] = {}
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:keepalive][:handler] = 1
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:keepalive][:handler] = "foo"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:keepalive][:handlers] = 1
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:keepalive][:handlers] = [1]
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:keepalive][:handlers] = ["foo"]
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:keepalive][:thresholds] = true
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:keepalive][:thresholds] = {}
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:keepalive][:thresholds][:warning] = "60"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:keepalive][:thresholds][:warning] = 60
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
    client[:keepalive][:thresholds][:critical] = "90"
    @validator.validate_client(client)
    expect(@validator.reset).to eq(1)
    client[:keepalive][:thresholds][:critical] = 90
    @validator.validate_client(client)
    expect(@validator.reset).to eq(0)
  end

  it "can run, validating client" do
    settings = {
      :client => {
        :name => "foo",
        :address => "127.0.0.1"
      }
    }
    @validator.run(settings, "client")
    expect(@validator.reset).to eq(6)
    settings[:client][:subscriptions] = ["bar"]
    @validator.run(settings, "client")
    expect(@validator.reset).to eq(5)
  end

  it "can validate an api definition" do
    api = true
    @validator.validate_api(api)
    expect(@validator.reset).to eq(1)
    api = {}
    @validator.validate_api(api)
    expect(@validator.reset).to eq(1)
    api[:port] = true
    @validator.validate_api(api)
    expect(@validator.reset).to eq(1)
    api[:port] = 4567
    @validator.validate_api(api)
    expect(@validator.reset).to eq(0)
    api[:bind] = true
    @validator.validate_api(api)
    expect(@validator.reset).to eq(1)
    api[:bind] = "127.0.0.1"
    @validator.validate_api(api)
    expect(@validator.reset).to eq(0)
    api[:user] = 1
    @validator.validate_api(api)
    expect(@validator.reset).to eq(2)
    api[:user] = "foo"
    @validator.validate_api(api)
    expect(@validator.reset).to eq(1)
    api[:password] = 1
    @validator.validate_api(api)
    expect(@validator.reset).to eq(1)
    api[:password] = "bar"
    @validator.validate_api(api)
    expect(@validator.reset).to eq(0)
  end

  it "can run, validating api" do
    settings = {
      :api => {
        :port => "4567"
      }
    }
    @validator.run(settings, "api")
    expect(@validator.reset).to eq(6)
    settings[:api][:port] = 4567
    @validator.run(settings, "api")
    expect(@validator.reset).to eq(5)
  end
end
