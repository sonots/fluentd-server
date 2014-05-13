require 'sinatra/activerecord'
require 'sinatra/decorator'
require 'fluentd_server/environments'
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

