require 'sinatra/activerecord'
require 'sinatra/decorator'
require 'fluentd_server/environment'
require 'fluentd_server/task_runner'
require 'ext/activerecord/acts_as_file'

class Delayed::Job < ActiveRecord::Base; end

class Post < ActiveRecord::Base
  include Sinatra::Decorator::Decoratable
  include FluentdServer::Logger

  validates :name, presence: true
  validates :body, presence: true

  if FluentdServer::Config.data_dir
    include ActiveRecord::ActsAsFile

    def filename
      File.join(FluentdServer::Config.data_dir, "#{self.name}.erb") if self.name
    end

    acts_as_file :body, :filename => self.instance_method(:filename)
  end

  def new?
    self.id.nil?
  end
end

class Task < ActiveRecord::Base
  include Sinatra::Decorator::Decoratable
  include FluentdServer::Logger
  include ActiveRecord::ActsAsFile
  include TaskRunner # task runnable codes are here

  def filename
    prefix = "#{self.id.to_s.rjust(4, '0')}" if self.id
    File.join(FluentdServer::Config.job_dir, "#{prefix}_result.txt") if prefix
  end

  acts_as_file :body, :filename => self.instance_method(:filename)

  def new?
    self.id.nil?
  end
end
