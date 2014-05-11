require 'sinatra/activerecord'
require 'sinatra/decorator'
require 'fluentd_server/environments'

class Post < ActiveRecord::Base
  include Sinatra::Decorator::Decoratable
  include FluentdServer::Logger

  validates :name, presence: true
  validates :body, presence: true

  if FluentdServer::Config.filesave?
    def filename
      filename = File.join(FluentdServer::Config.data_dir, "#{self.name}.erb") if self.name
    end

    def save_with_file
      filename = self.filename
      File.open(filename, 'w') do |f|
        f.flock(File::LOCK_EX) # inter-process locking. will be unlocked at closing file
        f.sync = true
        f.write(self.body)
        f.flush
      end if filename and self.body
      logger.debug "created/updated #{filename}"
      self.save_without_file
    end
    alias_method :save_without_file, :save
    alias_method :save, :save_with_file

    after_initialize do
      filename = self.filename
      # synchronize local file and db
      # todo: no synchronization, and using only local file would be fine in this case. 
      # todo: want to cache, but have to think of caching in each process, or use redis
      if filename and File.exist?(filename) and (self.updated_at.nil? or File.mtime(filename) > self.updated_at)
        self.body = File.read(filename)
        self.save_without_file
        logger.debug "read #{filename} and synchronized to db"
      end
    end
  end
end
