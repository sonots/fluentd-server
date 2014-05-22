require "bundler/gem_tasks"
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dotenv/tasks'
require 'fluentd_server/environment'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = ["-c", "-f progress"] # '--format specdoc'
  t.pattern = 'spec/**/*_spec.rb'
end
task :test => :spec
task :default => :spec

task :console => :dotenv do
  require "fluentd_server"
  require 'irb'
  # require 'irb/completion'
  ARGV.clear
  IRB.start
end
task :c => :console

require 'sinatra/activerecord/rake'
