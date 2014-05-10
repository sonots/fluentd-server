require 'logger'
require "fluentd_server/config"

module FluentdServer
  module Logger
    def self.included(klass)
      # To define logger *class* method
      klass.extend(self)
    end

    # for test
    def logger=(logger)
      FluentdServer.logger = logger
    end

    def logger
      FluentdServer.logger
    end
  end

  # for test
  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    return @logger if @logger

    log_path = FluentdServer::Logger::Config.log_path
    log_level = FluentdServer::Logger::Config.log_level
    # NOTE: Please note that ruby 2.0.0's Logger has a problem on log rotation.
    # Update to ruby 2.1.0. See https://github.com/ruby/ruby/pull/428 for details.
    log_shift_age = FluentdServer::Logger::Config.log_shift_age
    log_shift_size = FluentdServer::Logger::Config.log_shift_size
    @logger = ::Logger.new(log_path, log_shift_age, log_shift_size)
    @logger.level = log_level
    @logger
  end

  class Logger::Config
    def self.log_path(log_path = FluentdServer::Config.log_path)
      case log_path
      when 'STDOUT'
        $stdout
      when 'STDERR'
        $stderr
      else
        log_path
      end
    end

    def self.log_level(log_level = FluentdServer::Config.log_level)
      case log_level
      when 'debug'
        ::Logger::DEBUG
      when 'info'
        ::Logger::INFO
      when 'warn'
        ::Logger::WARN
      when 'error'
        ::Logger::ERROR
      when 'fatal'
        ::Logger::FATAL
      else
        raise ArgumentError, "invalid log_level #{log_level}"
      end
    end

    def self.log_shift_age(log_shift_age = FluentdServer::Config.log_shift_age)
      case log_shift_age
      when /\d+/
        log_shift_age.to_i
      when 'daily'
        log_shift_age
      when 'weekly'
        log_shift_age
      when 'monthly'
        log_shift_age
      else
        raise ArgumentError, "invalid log_shift_age #{log_shift_age}"
      end
    end

    def self.log_shift_size(log_shift_size = FluentdServer::Config.log_shift_size)
      log_shift_size.to_i
    end
  end

end
