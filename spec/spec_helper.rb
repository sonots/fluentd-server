ENV['RACK_ENV'] = 'test'
require 'rubygems'
require 'rspec'
require 'pry'
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'fluentd_server'
require 'fluentd_server/config'
require 'fluentd_server/environments'

unless FluentdServer::Config.test_database_url.start_with?('file')
  require 'rake'
  require 'sinatra/activerecord/rake'
  Rake::Task['db:migrate'].invoke
end
puts FluentdServer::Config.database_url

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end
