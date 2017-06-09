# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "sensu-settings"
  spec.version       = "10.1.0"
  spec.authors       = ["Sean Porter"]
  spec.email         = ["portertech@gmail.com"]
  spec.summary       = "The Sensu settings library, loader and validator"
  spec.description   = "The Sensu settings library, loader and validator"
  spec.homepage      = "https://github.com/sensu/sensu-settings"
  spec.license       = "MIT"

  spec.files         = Dir.glob("lib/**/*") + %w[sensu-settings.gemspec README.md LICENSE.txt]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "sensu-json", ">= 1.1.0"
  spec.add_dependency "parse-cron"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
