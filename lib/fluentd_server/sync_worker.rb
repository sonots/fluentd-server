require "fluentd_server/config"
require "fluentd_server/logger"
require "fluentd_server/sync_runner"

# reference: https://github.com/focuslight/focuslight/blob/master/lib/focuslight/worker.rb
# thanks!
class FluentdServer::SyncWorker
  include FluentdServer::Logger

  DEFAULT_INTERVAL = 60
  attr_reader :interval

  def self.start(opts = {})
    self.new(opts).start
  end

  def initialize(opts = {})
    @opts = opts
    @interval = opts[:interval] || FluentdServer::Config.sync_interval || DEFAULT_INTERVAL
    @signals = []
  end

  def update_next!
    now = Time.now
    @next_time = now - ( now.to_i % @interval ) + @interval
  end

  def start
    Signal.trap(:INT){  @signals << :INT }
    Signal.trap(:HUP){  @signals << :HUP }
    Signal.trap(:TERM){ @signals << :TERM }
    Signal.trap(:PIPE, "IGNORE")

    update_next!
    logger.info("[sync] first updater start in #{@next_time}")

    childpid = nil
    while sleep(0.5) do
      if childpid
        begin
          if Process.waitpid(childpid, Process::WNOHANG)
            #TODO: $? (Process::Status object)
            logger.debug("[sync] update finished pid: #{childpid}, code: #{$? >> 8}")
            logger.debug("[sync] next updater start in #{@next_time}")
            childpid = nil
          end
        rescue Errno::ECHILD
          logger.warn("[sync] no child process");
          childpid = nil
        end
      end

      unless @signals.empty?
        logger.warn("[sync] signals_received: #{@signals.join(',')}")
        break
      end

      next if Time.now < @next_time
      update_next!
      logger.debug("[sync] (#{@next_time}) updater start")

      if childpid
        logger.warn("[sync] previous updater exists, skipping this time")
        next
      end

      childpid = fork do
        FluentdServer::SyncRunner.run(@opts)
      end
    end

    if childpid
      logger.warn("[sync] waiting for updater process finishing")
      begin
        waitpid childpid
      rescue Errno::ECHILD
        # ignore
      end
    end
  end
end
