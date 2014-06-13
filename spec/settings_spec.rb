require File.join(File.dirname(__FILE__), "helpers")
require "sensu/settings"

describe "Sensu::Settings" do
  include Helpers

  before do
    @assets_dir = File.join(File.dirname(__FILE__), "assets")
    @config_file = File.join(@assets_dir, "config.json")
    @config_dir = File.join(@assets_dir, "conf.d")
    @app_dir = File.join(@assets_dir, "app")
  end

  it "can provide a loader" do
    expect(Sensu::Settings).to respond_to(:load)
    expect(Sensu::Settings.load).to be_an_instance_of(Sensu::Settings::Loader)
    settings = Sensu::Settings.load
    expect(settings).to respond_to(:validate)
  end

  it "can retrive the current loaded loader" do
    settings = Sensu::Settings.load
    expect(Sensu::Settings.get).to eq(settings)
    expect(Sensu::Settings.get).to eq(settings)
  end

  it "can load up a loader if one doesn't exist" do
    settings = Sensu::Settings.get
    expect(settings).to be_an_instance_of(Sensu::Settings::Loader)
    expect(Sensu::Settings.get).to eq(settings)
  end

  it "can load settings from the environment, a file, and a directory" do
    ENV["RABBITMQ_URL"] = "amqp://guest:guest@localhost:5672/"
    settings = Sensu::Settings.load(:config_file => @config_file, :config_dir => @config_dir)
    expect(settings[:rabbitmq]).to eq(ENV["RABBITMQ_URL"])
    expect(settings[:api][:port]).to eq(4567)
    expect(settings[:checks][:merger][:command]).to eq("echo -n merger")
    expect(settings[:checks][:merger][:subscribers]).to eq(["foo", "bar"])
    expect(settings[:checks][:nested][:command]).to eq("true")
    expect(ENV["SENSU_CONFIG_FILES"].split(":")).to eq(settings.loaded_files)
    ENV["RABBITMQ_URL"] = nil
  end

  it "can load settings from files in multiple directories" do
    settings = Sensu::Settings.load(:config_dirs => [@config_dir, @app_dir])
    expect(settings[:checks][:merger][:command]).to eq("echo -n merger")
    expect(settings[:checks][:app_http_endpoint][:command]).to eq("check-http.rb -u https://localhost/ping -q pong")
  end
end
