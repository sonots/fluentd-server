require 'fluentd_server'
require 'dotenv'
Dotenv.load

module FluentdServer::Config
  def self.data_dir=(data_dir)
    @data_dir = data_dir
  end

  def self.data_dir
    @data_dir
  end

  def self.test_database_url
    # ActiveRecord requires DATABASE_URL to be set
    ENV['DATABASE_URL'] = ENV.fetch('TEST_DATABASE_URL', 'sqlite3:data/test.db')
  end

  def self.database_url
    ENV.fetch('DATABASE_URL', 'sqlite3:data/fluentd_server.db')
  end

  def self.log_path
    ENV.fetch('LOG_PATH', 'STDOUT')
  end

  def self.log_level
    ENV.fetch('LOG_LEVEL', 'debug')
  end

  def self.log_shift_age
    ENV.fetch('LOG_SHIFT_AGE', '0')
  end

  def self.log_shift_size
    ENV.fetch('LOG_SHIFT_SIZE', '1048576')
  end
end
