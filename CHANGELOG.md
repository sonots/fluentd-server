# 0.3.1

Enhancements:

* Add `fluentd-server sync` command
* Add `fluentd-server td-agent-start` command
* Add `fluentd-server td-agent-stop` command
* Add `fluentd-server td-agent-reload` command
* Add `fluentd-server td-agent-restart` command
* Add `fluentd-server td-agent-condrestart` command
* Add `fluentd-server td-agent-status` command
* Add `fluentd-server td-agent-configtest` command

Changes:

* Rename `fluentd-server sync` command to `fluentd-server sync-worker`
* Rename `fluentd-server job` command to `fluentd-server job-worker`
* Rename `fluentd-server job_clear` command to `fluentd-server job-clean`

# 0.3.0

Enhancements:

* Add sync_worker

Changes:

* Use env LOCAL_STORAGE rather than DATA_DIR to enable local file storage feature

# 0.2.0

Enhancements:

* Support restarting td-agent via serf
  * Created serf-td-agent gem
  * Introduce Resque
  * Ajax reload of command result
* Save/load the content of configuration into/from a file (experimental)
  * Created acts_as_file gem

# 0.1.0

First version

