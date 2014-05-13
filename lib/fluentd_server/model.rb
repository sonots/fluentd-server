require 'sinatra/decorator'
require 'fluentd_server/environments'

unless FluentdServer::Config.database_url.start_with?('file')
  require 'sinatra/activerecord'
  class Post < ActiveRecord::Base
    include Sinatra::Decorator::Decoratable
    validates :name, presence: true
    validates :body, presence: true
  end
else
  # File-based record
  class Post
    attr_accessor :name, :body, :created_at, :updated_at
    attr_accessor :cached_at
    include Sinatra::Decorator::Decoratable
    include FluentdServer::Logger

    def initialize(params = {})
      self.name = params[:name] if params[:name]
      self.body = params[:body] if params[:body]
      self.created_at = params[:created_at] if params[:created_at]
      self.updated_at = params[:updated_at] if params[:updated_at]
    end

    def self.new_with_file(filename)
      self.new({
        name: File.basename(filename).chomp(".erb"),
        body: nil, # File.read(filename) # do not read yet because it takes time
        created_at: File.ctime(filename),
        updated_at: File.mtime(filename),
      })
    end

    def to_h
      {
        name: self.name,
        body: self.body,
        created_at: self.created_at,
        updated_at: self.updated_at,
      }
    end

    def to_json
      self.to_h.to_json
    end
    
    def self.create(params = {})
      post = self.new(params)
      self.new_with_file(post.filename) if post.save
    end

    def update(params = {})
      params.each {|key, val|
        self.send("#{key}=", val)
      }
      self.save
    end

    def destroy
      File.unlink(self.filename)
    end

    def body=(body)
      self.cached_at = Time.now
      @body = body
    end

    def body
      filename = self.filename
      if filename and File.exist?(filename) and (self.cached_at.nil? or File.mtime(filename) > self.cached_at)
        logger.debug "read to cache #{filename}"
        self.body = File.read(filename)
      else
        logger.debug "read from cache #{filename}"
        @body
      end
    end

    def self.filename(name)
      File.join(FluentdServer::Config.data_dir, "#{name}.erb")
    end

    def filename
      @filename ||= Post.filename(self.name)
    end
    
    def save
      if filename = self.filename and body = self.body
        File.open(filename, 'w') do |f|
          f.flock(File::LOCK_EX)
          f.sync = true
          f.write(body)
          f.flush
        end
        self.updated_at = self.cached_at = File.mtime(filename)
      end
      logger.debug "created or updated #{filename}"
      true
    end

    # get all posts
    # sorting function is not implemented yet, but sorting by name
    def self.order(*args)
      Dir.glob("#{FluentdServer::Config.data_dir}/*.erb").sort.map do |filename|
        Post.new_with_file(filename)
      end
    end

    def self.count
      Dir.glob("#{FluentdServer::Config.data_dir}/*.erb").size
    end

    def self.first
      filename = Dir.glob("#{FluentdServer::Config.data_dir}/*.erb").sort.first
      Post.new_with_file(filename)
    end

    def self.find_by(params)
      Post.new_with_file(Post.filename(params[:name]))
    end
    
    def self.delete_all
      Dir.glob("#{FluentdServer::Config.data_dir}/*.erb").each do |filename|
        File.unlink(filename)
      end
    end
  end
end
