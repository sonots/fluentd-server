require "fileutils"
require "dotenv"
require "thor"

require "fluentd_server"

class FluentdServer::CLI < Thor
  BASE_DIR = File.join(Dir.pwd, "fluentd_server")
  DATA_DIR = File.join(BASE_DIR, "data")
  LOG_DIR = File.join(BASE_DIR, "log")
  LOG_FILE = File.join(LOG_DIR, "application.log")
  ENV_FILE = File.join(BASE_DIR, ".env")
  PROCFILE = File.join(BASE_DIR, "Procfile")
  CONFIGRU_FILE = File.join(BASE_DIR, "config.ru")

  DEFAULT_DOTENV =<<-EOS
PORT=5126
HOST=0.0.0.0
DATA_DIR=#{DATA_DIR}
DATABASE_URL=sqlite3:#{DATA_DIR}/fluentd_server.db
LOG_PATH=#{LOG_FILE}
LOG_LEVEL=warn
EOS

  DEFAULT_PROCFILE =<<-EOS
web: unicorn -E production -p $PORT -o $HOST
EOS

  default_command :start

  desc "new", "Creates fluentd_server resource directory"
  def new
    FileUtils.mkdir_p(LOG_DIR)
    File.write ENV_FILE, DEFAULT_DOTENV
    File.write PROCFILE, DEFAULT_PROCFILE
    configru_file = File.expand_path("../../../config.ru", __FILE__)
    FileUtils.copy(configru_file, CONFIGRU_FILE)
  end

  desc "start", "Sartup fluentd_server"
  def start
    Dotenv.load
    require "foreman/cli"
    Foreman::CLI.new.invoke(:start, [], {})
  end

  no_tasks do
    def abort(msg)
      $stderr.puts msg
      exit 1
    end
  end
end
