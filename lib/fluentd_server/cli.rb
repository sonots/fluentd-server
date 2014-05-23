require "fileutils"
require "dotenv"
require "thor"
require 'fluentd_server'

class FluentdServer::CLI < Thor
  BASE_DIR = File.join(Dir.pwd, "fluentd-server")
  DATA_DIR = File.join(BASE_DIR, "data")
  LOG_DIR = File.join(BASE_DIR, "log")
  LOG_FILE = File.join(LOG_DIR, "application.log")
  ENV_FILE = File.join(BASE_DIR, ".env")
  PROCFILE = File.join(BASE_DIR, "Procfile")
  CONFIGRU_FILE = File.join(BASE_DIR, "config.ru")
  CONFIG_DIR= File.join(BASE_DIR, "config")

  DEFAULT_DOTENV =<<-EOS
PORT=5126
HOST=0.0.0.0
DATABASE_URL=sqlite3:#{DATA_DIR}/fluentd_server.db
LOG_PATH=#{LOG_FILE}
LOG_LEVEL=warn
EOS

  DEFAULT_PROCFILE =<<-EOS
web: unicorn -E production -p $PORT -o $HOST -c config/unicorn.conf
EOS

  default_command :start

  def initialize(args = [], opts = [], config = {})
    super(args, opts, config)
  end

  desc "new", "Creates fluentd-server resource directory"
  def new
    FileUtils.mkdir_p(LOG_DIR)
    File.write ENV_FILE, DEFAULT_DOTENV
    File.write PROCFILE, DEFAULT_PROCFILE
    FileUtils.cp(File.expand_path("../../../config.ru", __FILE__), CONFIGRU_FILE)
    FileUtils.cp_r(File.expand_path("../../../config", __FILE__), CONFIG_DIR)
    puts 'fluentd-server new finished.'
  end

  desc "init", "Creates database schema"
  def init
    Dotenv.load
    require 'fluentd_server/environment'
    require 'rake'
    require 'sinatra/activerecord/rake'
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path("../../../db", __FILE__)
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [File.expand_path("../../../db/migrate", __FILE__)]
    # ToDo: Fix that db:migrate raises an error in the case of sqlite3 like
    # SQLite3::SQLException: database schema has changed: INSERT INTO "schema_migrations" ("version") VALUES (?)
    # Rake::Task['db:migrate'].invoke
    # Use db:schema:load after generating db/schema.rb by executing db:migrate several times for now
    Rake::Task['db:schema:load'].invoke
    puts 'fluentd-server init finished.'
  end

  desc "migrate", "Migrate database schema"
  def migrate
    Dotenv.load
    require 'fluentd_server/environment'
    require 'rake'
    require 'sinatra/activerecord/rake'
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path("../../../db", __FILE__)
    ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [File.expand_path("../../../db/migrate", __FILE__)]
    Rake::Task['db:migrate'].invoke
  end

  desc "start", "Sartup fluentd_server"
  def start
    self.migrate # do migration before start not to forget on updation
    require "foreman/cli"
    Foreman::CLI.new.invoke(:start, [], {})
  end

  # reference: https://gist.github.com/robhurring/732327
  desc "job", "Sartup fluentd_server job worker"
  def job
    Dotenv.load
    require 'delayed_job'
    require 'fluentd_server/model'
    worker_options = {
      :min_priority => ENV['MIN_PRIORITY'],
      :max_priority => ENV['MAX_PRIORITY'],
      :queues => (ENV['QUEUES'] || ENV['QUEUE'] || '').split(','),
      :quiet => false
    }
    Delayed::Worker.new(worker_options).start
  end

  desc "job_clear", "Clear fluentd_server delayed_job queue"
  def job_clear
    Dotenv.load
    require 'delayed_job'
    require 'fluentd_server/model'
    Delayed::Job.delete_all
  end

  no_tasks do
    def abort(msg)
      $stderr.puts msg
      exit 1
    end
  end
end
