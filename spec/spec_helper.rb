require 'rubygems'
require 'rspec'
require 'pry'
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

ENV['RACK_ENV'] = 'test'

# NOTE: DATABASE_URL in .env must be commented out
require 'fluentd_server'
require 'fluentd_server/environment'
require 'rake'
require 'sinatra/activerecord/rake'
Rake::Task['db:schema:load'].invoke

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end
