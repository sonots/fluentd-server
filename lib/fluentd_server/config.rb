require 'sinatra'
require 'sinatra/activerecord'
require 'fluentd_server'
require 'dotenv'
Dotenv.load

module FluentdServer::Config
  def self.data_dir
    ENV['DATA_DIR'] == "" ? nil : ENV['DATA_DIR']
  end

  def self.database_url
    ENV.fetch('DATABASE_URL', 'sqlite3:data/fluentd_server.db')
  end

  def self.job_dir
    ENV.fetch('JOB_DIR', 'jobs')
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

  def self.task_max_num
    ENV.fetch('TASK_MAX_NUM', '20').to_i
  end
end
