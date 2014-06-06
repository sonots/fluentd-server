require 'fluentd_server/model'
require 'fluentd_server/logger'

class FluentdServer::SyncRunner
  include FluentdServer::Logger

  def self.run(opts = {})
    self.new(opts).run
  end

  def initialize(opts = {})
  end

  def run
    return nil unless FluentdServer::Config.local_storage
    plus, minus = find_diff
    create(plus)
    delete(minus)
  end

  def find_locals
    return [] unless FluentdServer::Config.local_storage
    names = []
    Dir.chdir(FluentdServer::Config.data_dir) do
      Dir.glob("*.erb") do |filename|
        names << filename.chomp('.erb')
      end
    end
    names
  end

  def create(names)
    # ToDo: bulk insert with sqlite, postgresql? use activerecord-import for mysql2
    logger.debug "[sync] create #{names}"
    names.each do |name|
      begin
        Post.create(name: name)
      rescue ActiveRecord::RecordNotUnique => e
        logger.debug "#{e.class} #{e.message} #{name}"
      rescue => e
        logger.warn "#{e.class} #{e.message} #{name}"
      end
    end
  end

  def delete(names)
    logger.debug "[sync] remove #{names}"
    begin
      Post.where(:name => names).delete_all
    rescue => e
      logger.warn "#{e.class} #{e.message} #{names}"
    end
  end

  # Find difference between given array of paths and paths stored in DB
  #
  # @param [Integer] batch_size The batch size of a select query
  # @return [Array] Plus (array) and minus (array) differences
  def find_diff(batch_size: 1000)
    names = find_locals
    plus  = names
    minus = []
    Post.select('id, name').find_in_batches(batch_size: batch_size) do |batches|
      batches = batches.map(&:name)
      plus   -= batches
      minus  += (batches - names)
    end
    [plus, minus]
  end
end
