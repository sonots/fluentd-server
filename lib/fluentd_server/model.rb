require 'sinatra/activerecord'
require 'sinatra/decorator'
require 'fluentd_server/environment'
require 'fluentd_server/task_runner'
require 'ext/acts_as_file'

class Delayed::Job < ActiveRecord::Base; end

class Post < ActiveRecord::Base
  include Sinatra::Decorator::Decoratable
  include FluentdServer::Logger

  validates :name, presence: true
  validates :body, presence: true

  if FluentdServer::Config.data_dir
    include ActsAsFile

    def filename
      File.join(FluentdServer::Config.data_dir, "#{self.name}.erb") if self.name
    end

    acts_as_file :body => self.instance_method(:filename)
  end

  def new?
    self.id.nil?
  end
end

class Task < ActiveRecord::Base
  include Sinatra::Decorator::Decoratable
  include FluentdServer::Logger
  include ActsAsFile
  include TaskRunner # task runnable codes are here

  def filename
    prefix = "#{self.id.to_s.rjust(4, '0')}" if self.id
    File.join(FluentdServer::Config.job_dir, "#{prefix}_result.txt") if prefix
  end

  acts_as_file :body => self.instance_method(:filename)

  def finished?
    !self.exit_code.nil?
  end

  def successful?
    self.finished? and self.exit_code == 0
  end

  def error?
    self.finished? and self.exit_code != 0
  end

  def new?
    self.id.nil?
  end

  def self.create_and_delete(*args)
    created = self.create(*args)
    if self.count > FluentdServer::Config.task_max_num
      oldest = self.first
      oldest.destroy_with_file
    end
    created
  end
end
