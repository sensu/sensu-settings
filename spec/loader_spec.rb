require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings/loader"

describe "Sensu::Settings::Loader" do
  include Helpers

  before do
    @loader = Sensu::Settings::Loader.new
  end

  it "provides a loader API" do
    @loader.should respond_to(:load, :validate!)
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

  it "can load settings from the environment and the paths provided" do
    ENV["RABBITMQ_URL"] = "amqp://guest:guest@localhost:5672/"
    settings = @loader.load
    settings[:rabbitmq].should eq(ENV["RABBITMQ_URL"])
    ENV["RABBITMQ_URL"] = nil
  end

  it "can validate loaded settings" do
    failures = @loader.validate!
    failures.size.should eq(0)
  end

  it "can provide indifferent access to settings" do
    @loader[:checks].should be_kind_of(Hash)
    @loader["checks"].should be_kind_of(Hash)
  end
end
