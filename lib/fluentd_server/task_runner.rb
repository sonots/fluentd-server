# included by class Task
module TaskRunner
  def self.included(klass)
    require 'fileutils'
    klass.extend(ClassMethods)
  end

  def restart
    system(write_event_header('restart'))
    cmd = serf_event('restart')
    logger.debug "run #{cmd}"
    system(cmd)
  end
 
  def status
    system(write_query_header('status'))
    self.delay.delayed_status
  end

  def delayed_status
    cmd = serf_query('status')
    logger.debug "run #{cmd}"
    system(cmd)
  end

  def configtest
    system(write_query_header('configtest'))
    self.delay.delayed_configtest
  end

  def delayed_configtest
    cmd = serf_query('configtest')
    logger.debug "run #{cmd}"
    system(cmd)
  end

  ## delayed_job hooks

  def before(job)
    @job = job
  end

  def failure
    logger.warn "job #{@job.attributes} failed"
  end

  ## helpers

  def write_event_header(cmd)
    "echo '$ serf event td-agent-#{cmd}' > #{self.filename}"
  end

  def write_query_header(cmd)
    "echo '$ serf query td-agent-#{cmd}' > #{self.filename}"
  end

  # serf event works asynchronously, so it does not take time
  def serf_event(cmd)
    "#{self.class.serf_path} event td-agent-#{cmd} >> #{self.filename} 2>&1"
  end

  # serf query works synchronously, so it takes time
  def serf_query(cmd)
    "#{self.class.serf_path} query td-agent-#{cmd} >> #{self.filename} 2>&1"
  end

  module ClassMethods
    def serf_path
      @serf_path ||= "#{find_path_gem('serf-td-agent')}/bin/serf"
    end

    # from gem-path gem
    def find_path_gem name
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
end

