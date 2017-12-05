
# frozen_string_literal: true

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "logger/key_value_formatter/version"

Gem::Specification.new do |spec|
  spec.name          = "kv_formatter"
  spec.version       = Logger::KeyValueFormatter::VERSION
  spec.authors       = ["Michał Begejowicz"]
  spec.email         = ["michal.begejowicz@codesthq.com"]

  spec.summary       = "Adds Logger::KeyValueFormatter which formats log output in key=value format"
  spec.description   = "This format is similar to how Heroku formats their logs and Logstash parses them with kv filter"
  spec.homepage      = "https://github.com/adtaily/kv_formatter"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.49"
  spec.add_development_dependency "timecop", "~> 0.9"
end
