require 'sinatra'
require 'fluentd_server/config'
require 'fluentd_server/logger'

def configure_database(database_url)
  if database_url.start_with?('file')
    uri = URI.parse(database_url)
    FluentdServer::Config.data_dir = uri.path[1..-1]
  else
    require 'sinatra/activerecord'
    ActiveRecord::Base.logger = FluentdServer.logger
    I18n.enforce_available_locales = false

    if database_url.start_with?('sqlite')
      set :database, database_url
    else
      db = URI.parse(database_url)
      ActiveRecord::Base.establish_connection(
        # heroku sets DATABASE_URL like postgres://...
        :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
        :host     => db.host,
        :username => db.user,
        :password => db.password,
        :database => db.path[1..-1],
        :encoding => 'utf8'
      )
    end
  end
end

configure do
  set :show_exceptions, true
end

configure :production, :development do
  configure_database(FluentdServer::Config.database_url)
end

configure :test do
  configure_database(FluentdServer::Config.test_database_url)
end
