require 'sinatra/activerecord'
require 'sinatra/decorator'
require 'fluentd_server/environment'
require 'ext/activerecord/acts_as_file'

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
end

module Delayed; end
class Delayed::Job < ActiveRecord::Base
  self.table_name = 'delayed_jobs'
  include Sinatra::Decorator::Decoratable
end
