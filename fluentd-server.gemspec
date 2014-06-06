# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluentd_server/version'

Gem::Specification.new do |spec|
  spec.name          = "fluentd-server"
  spec.version       = FluentdServer::VERSION
  spec.authors       = ["Naotoshi Seo"]
  spec.email         = ["sonots@gmail.com"]
  spec.description   = %q{Fluentd config distribution server}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/sonots/fluentd-server"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "dotenv"
  spec.add_runtime_dependency "foreman"
  spec.add_runtime_dependency "thor"

  spec.add_runtime_dependency "sinatra"
  spec.add_runtime_dependency "activerecord"
  spec.add_runtime_dependency "sinatra-contrib"
  spec.add_runtime_dependency "sinatra-activerecord"
  spec.add_runtime_dependency 'sinatra-flash'
  spec.add_runtime_dependency 'sinatra-redirect-with-flash'
  spec.add_runtime_dependency 'sinatra-decorator'
  spec.add_runtime_dependency 'slim'
  spec.add_runtime_dependency "unicorn"
  spec.add_runtime_dependency "unicorn-worker-killer"
  spec.add_runtime_dependency "delayed_job_active_record"
  spec.add_runtime_dependency "daemons"
  spec.add_runtime_dependency "serf-td-agent"
  spec.add_runtime_dependency "acts_as_file"
  # spec.add_runtime_dependency 'sqlite3'
end
