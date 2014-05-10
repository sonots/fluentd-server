require 'rubygems'
require 'rspec'
$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')

require 'fluentd_server'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end
