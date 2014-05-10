require 'sinatra'
require 'sinatra/activerecord'
require 'fluentd_server/config'
require 'fluentd_server/logger'

configure do
  set :show_exceptions, true
  ActiveRecord::Base.logger = FluentdServer.logger
  I18n.enforce_available_locales = false

  if FluentdServer::Config.database_url.include?('sqlite')
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
