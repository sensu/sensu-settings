require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings/loader"

describe "Sensu::Settings::Loader" do
  include Helpers

  before do
    @loader = Sensu::Settings::Loader.new
    @assets_dir = File.join(File.dirname(__FILE__), "assets")
    @config_file = File.join(@assets_dir, "config.json")
    @config_dir = File.join(@assets_dir, "conf.d")
  end

  it "can provide a loader API" do
    @loader.should respond_to(:load, :validate!)
  end

  it "can provide indifferent access to settings" do
    @loader[:checks].should be_kind_of(Hash)
    @loader["checks"].should be_kind_of(Hash)
  end

  it "can validate loaded settings" do
    failures = @loader.validate!
    failures.size.should eq(0)
  end

  it "can load RabbitMQ settings from the environment" do
    ENV["RABBITMQ_URL"] = "amqp://guest:guest@localhost:5672/"
    @loader.load_env
    @loader.warnings.size.should eq(1)
    ENV["RABBITMQ_URL"] = nil
  end

  it "can load Redis settings from the environment" do
    ENV["REDIS_URL"] = "redis://username:password@localhost:6789"
    @loader.load_env
    @loader.warnings.size.should eq(1)
    ENV["REDIS_URL"] = nil
  end

  it "can load Sensu API settings from the environment" do
    ENV["API_PORT"] = "4567"
    @loader.load_env
    @loader.warnings.size.should eq(1)
    ENV["API_PORT"] = nil
  end

  it "can load Redis and Sensu API settings from the environment using alternative variables" do
    ENV["REDISTOGO_URL"] = "redis://username:password@localhost:6789"
    ENV["PORT"] = "4567"
    @loader.load_env
    @loader.warnings.size.should eq(2)
    ENV["REDISTOGO_URL"] = nil
    ENV["PORT"] = nil
  end

  it "can load settings from a file" do
    @loader.load_file(@config_file)
    @loader.warnings.size.should eq(1)
    warning = @loader.warnings.first
    warning[:object].should eq(File.expand_path(@config_file))
    warning[:message].should eq("loading config file")
    @loader[:api][:port].should eq(4567)
    @loader["api"]["port"].should eq(4567)
  end

  it "can load settings from a file and validate them" do
    @loader.load_file(@config_file)
    failures = @loader.validate!
    reasons = failures.map do |failure|
      failure[:message]
    end
    reasons.should include("check interval must be an integer")
  end

  it "can attempt to load settings from a nonexistent file" do
    @loader.load_file("/tmp/bananaphone")
    warnings = @loader.warnings
    warnings.size.should eq(2)
    messages = warnings.map do |warning|
      warning[:message]
    end
    messages.should include("config file does not exist or is not readable")
    messages.should include("ignoring config file")
  end

  it "can attempt to load settings from a file with invalid JSON" do
    @loader.load_file(File.join(@assets_dir, "invalid.json"))
    warnings = @loader.warnings
    warnings.size.should eq(3)
    messages = warnings.map do |warning|
      warning[:message]
    end
    messages.should include("loading config file")
    messages.should include("config file must be valid json")
    messages.should include("ignoring config file")
  end

  it "can load settings from files in a directory" do
    @loader.load_directory(@config_dir)
    warnings = @loader.warnings
    warnings.size.should eq(4)
    messages = warnings.map do |warning|
      warning[:message]
    end
    messages.should include("loading config files from directory")
    messages.should include("loading config file")
    messages.should include("config file applied changes")
    @loader[:checks][:nested][:command].should eq("true")
  end

  it "can attempt to load settings from files in a nonexistent directory" do
    @loader.load_directory("/tmp/rottentomatos")
    @loader.warnings.size.should eq(1)
    warning = @loader.warnings.first
    warning[:message].should eq("loading config files from directory")
  end

  it "can load settings from the environment, a file, and a directory" do
    ENV["RABBITMQ_URL"] = "amqp://guest:guest@localhost:5672/"
    settings = @loader.load(:config_file => @config_file, :config_dir => @config_dir)
    settings[:rabbitmq].should eq(ENV["RABBITMQ_URL"])
    settings[:api][:port].should eq(4567)
    settings[:checks][:merger][:command].should eq("echo -n merger")
    settings[:checks][:merger][:subscribers].should eq(["foo", "bar"])
    settings[:checks][:nested][:command].should eq("true")
    ENV["SENSU_CONFIG_FILES"].split(":").should eq(@loader.loaded_files)
    ENV["RABBITMQ_URL"] = nil
  end

  it "can load settings and determine if certain definitions exist" do
    @loader.load(:config_file => @config_file, :config_dir => @config_dir)
    @loader.check_exists?("nonexistent").should be_false
    @loader.check_exists?("tokens").should be_true
    @loader.filter_exists?("nonexistent").should be_false
    @loader.filter_exists?("development").should be_true
    @loader.mutator_exists?("nonexistent").should be_false
    @loader.mutator_exists?("noop").should be_true
    @loader.handler_exists?("nonexistent").should be_false
    @loader.handler_exists?("default").should be_true
  end

  it "can load settings and provide setting category accessors" do
    @loader.load(:config_file => @config_file, :config_dir => @config_dir)
    @loader.checks.should be_kind_of(Array)
    @loader.checks.should_not be_empty
    check = @loader.checks.detect do |check|
      check[:name] == "tokens"
    end
    check[:interval].should eq(1)
    @loader.filters.should be_kind_of(Array)
    @loader.filters.should_not be_empty
    filter = @loader.filters.detect do |filter|
      filter[:name] == "development"
    end
    filter[:negate].should be_true
    @loader.mutators.should be_kind_of(Array)
    @loader.mutators.should_not be_empty
    mutator = @loader.mutators.detect do |mutator|
      mutator[:name] == "noop"
    end
    mutator[:command].should eq("cat")
    @loader.handlers.should be_kind_of(Array)
    @loader.handlers.should_not be_empty
    handler = @loader.handlers.detect do |handler|
      handler[:name] == "default"
    end
    handler[:type].should eq("set")
  end
end
