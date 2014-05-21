require 'sinatra'
require 'sinatra/activerecord'
require 'fluentd_server/config'
require 'fluentd_server/logger'

ROOT = File.expand_path('../../..', __FILE__)

configure do
  set :show_exceptions, true
  ActiveRecord::Base.logger = FluentdServer.logger
  I18n.enforce_available_locales = false
end

configure :production, :development do
  if FluentdServer::Config.database_url.start_with?('sqlite')
    set :database, FluentdServer::Config.database_url 
  else
    # DATABASE_URL => "postgres://randuser:randpass@randhost:randport/randdb" on heroku
    db = URI.parse(FluentdServer::Config.database_url)
    ActiveRecord::Base.establish_connection(
      :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
      :host     => db.host,
      :username => db.user,
      :password => db.password,
      :database => db.path[1..-1],
      :encoding => 'utf8'
    )
  end
end

configure :test do
  ActiveRecord::Base.establish_connection(
    :adapter  => 'sqlite3',
    :database => ':memory:'
  )
end

# Configure DelayedJob
require 'delayed_job'
configure do
  Delayed::Worker.backend = :active_record # This defines Delayed::Job model
  Delayed::Worker.logger = FluentdServer.logger
end

configure :development, :test do
  Delayed::Worker.destroy_failed_jobs = true
  Delayed::Worker.sleep_delay = 5
  Delayed::Worker.max_attempts = 5
  Delayed::Worker.max_run_time = 5.minutes
end
