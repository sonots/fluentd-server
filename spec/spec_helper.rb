ENV['RACK_ENV'] = 'test'
require 'rubygems'
require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'fluentd_server'

require 'fluentd_server/environments'
require 'rake'
require 'sinatra/activerecord/rake'
Rake::Task['db:migrate'].invoke

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end
