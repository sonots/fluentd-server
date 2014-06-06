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

