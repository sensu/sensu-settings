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
    Sensu::Settings.should respond_to(:load)
    Sensu::Settings.load.should be_an_instance_of(Sensu::Settings::Loader)
    settings = Sensu::Settings.load
    settings.should respond_to(:validate)
  end

  it "can retrive the current loaded loader" do
    settings = Sensu::Settings.load
    Sensu::Settings.get.should eq(settings)
    Sensu::Settings.get.should eq(settings)
  end

  it "can load up a loader if one doesn't exist" do
    settings = Sensu::Settings.get
    settings.should be_an_instance_of(Sensu::Settings::Loader)
    Sensu::Settings.get.should eq(settings)
  end

  it "can load settings from the environment, a file, and a directory" do
    ENV["RABBITMQ_URL"] = "amqp://guest:guest@localhost:5672/"
    settings = Sensu::Settings.load(:config_file => @config_file, :config_dir => @config_dir)
    settings[:rabbitmq].should eq(ENV["RABBITMQ_URL"])
    settings[:api][:port].should eq(4567)
    settings[:checks][:merger][:command].should eq("echo -n merger")
    settings[:checks][:merger][:subscribers].should eq(["foo", "bar"])
    settings[:checks][:nested][:command].should eq("true")
    ENV["SENSU_CONFIG_FILES"].split(":").should eq(settings.loaded_files)
    ENV["RABBITMQ_URL"] = nil
  end

  it "can load settings from files in multiple directories" do
    settings = Sensu::Settings.load(:config_dirs => [@config_dir, @app_dir])
    settings[:checks][:merger][:command].should eq("echo -n merger")
    settings[:checks][:app_http_endpoint][:command].should eq("check-http.rb -u https://localhost/ping -q pong")
  end
end
