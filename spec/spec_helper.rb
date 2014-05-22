ENV['RACK_ENV'] = 'test'
require 'rubygems'
require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
require 'fluentd_server'
require 'pry'

require 'fluentd_server/environment'
require 'rake'
require 'sinatra/activerecord/rake'
Rake::Task['db:schema:load'].invoke

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end
