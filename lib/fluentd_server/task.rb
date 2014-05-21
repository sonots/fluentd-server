require 'fileutils'
require 'sinatra/activerecord'
require 'fluentd_server/environment'
require 'fluentd_server/logger'

class Task
  include FluentdServer::Logger

  def restart
    cmd = serf_event('restart')
    logger.debug "run #{cmd}"
    system(cmd)
  end
  
  def status
    cmd = serf_query('status')
    logger.debug "run #{cmd}"
    system(cmd)
  end
  handle_asynchronously :status

  ## hooks

  def before(job)
    @job = job
    logger.debug "create #{job_dir}"
    FileUtils.mkdir_p(job_dir)
  end

  def failure
    logger.warn "job #{@job.attributes} failed"
  end

  ## helpers

  def job_dir
    "#{ROOT}/jobs/#{@job.id}"
  end

  # serf event works asynchronously, so it does not take time
  def serf_event(cmd)
    "#{self.class.serf_path} event td-agent-#{cmd} > #{job_dir}/result.txt 2>&1"
  end

  # serf query works synchronously, so it takes time
  def serf_query(cmd)
    "#{self.class.serf_path} query td-agent-#{cmd} > #{job_dir}/result.txt 2>&1"
  end

  def self.serf_path
    @serf_path ||= "#{self.find_path_gem('serf-td-agent')}/bin/serf"
  end

  # from gem-path gem
  def self.find_path_gem name
    path_gem = Gem.path.find do |base|
      path_gem = $LOAD_PATH.find do |path|
        path_gem = path[%r{#{base}/gems/#{name}\-[^/-]+/}]
        break path_gem if path_gem
      end
      break path_gem if path_gem
    end
    path_gem[0...-1] if path_gem
  end
end
