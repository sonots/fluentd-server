# Fluentd Server

[![Build Status](https://secure.travis-ci.org/sonots/fluentd-server.png?branch=master)](http://travis-ci.org/sonots/fluentd-server)
[![Coverage Status](https://coveralls.io/repos/sonots/fluentd-server/badge.png?branch=master)](https://coveralls.io/r/sonots/fluentd-server?branch=master)

A Fluentd config distribution server

Demo: [http://fluentd-server.herokuapp.com](http://fluentd-server.herokuapp.com)

## What You Can Do

With Fluentd Server, you can manage fluentd configuration files centrally with `erb`. 

For example, you may create a config post whose name is `worker` as:

```
<source>
  type forward
  port <%= port %>
</source>

<match **>
  type stdout
</match>
```

Then you can download the config via an API whose uri is like `/api/worker?port=24224` where its query parameters are replaced with variables in the erb. 
The downloaded contents should become as follows:

```
<source>
  type forward
  port 24224
</source>

<match **>
  type stdout
</match>
```

## How to Use

The `include` directive of fluentd config supports `http`, so write just one line on your fluentd.conf as:

```
# /etc/fluentd.conf
include http://fqdn.to.fluentd-server/api/:name?port=24224
```

so that it will download the real configuration from the Fluentd Server where :name is the name of your post. 

## Installation

Prerequisites

* SQLite
* Ruby 2.0 or later

### From Gem package

Easy steps on installation with gem and SQLite.

```bash
$ gem install fluentd-server
$ gem install sqlite3
$ fluentd-server new
$ cd fluentd-server
$ fluentd-server init # creates database scheme on SQLite
$ fluentd-server start
```

Then see `http://localhost:5126/`.

### From Git repository

Install from git repository. 

```bash
$ git clone https://github.com/sonots/fluentd-server.git
$ cd fluentd-server
$ bundle
$ bundle exec fluentd-server init # creates database scheme on SQLite
$ bundle exec fluentd-server start
```

Then see `http://localhost:5126/`. 

## Configuration

To configure fluentd-server, edit the `.env` file in the project root directory.

The default configuration is as follows:

```
PORT=5126
HOST=0.0.0.0
# DATABASE_URL=sqlite3:data/fluentd_server.db
# JOB_DIR=jobs
# LOG_PATH=STDOUT
# LOG_LEVEL=debug
# LOG_SHIFT_AGE=0
# LOG_SHIFT_SIZE=1048576
```

## HTTP API

See [API.md](API.md).

### Use Fluentd Server from Command Line

For the case you want to edit Fluentd configuration files from your favorite editors rather than from the Web UI, `LOCAL STORAGE` feature is available.
With this feature, you should also be able to manage your configuration files with git (or any VCS).

To use this feature, enable `LOCAL_STORAGE` in `.env` file as:

```
LOCAL_STORAGE=true
DATA_DIR=data
SYNC_INTERVAL=60
```

where the `DATA_DIR` is the location to place your configuration files locally, and the `SYNC_INTERVAL` is the interval where a synchronization worker works.

Place your `erb` files in the `DATA_DIR` directory, and please execute `sync` command to synchronize the file existence information with DB
when you newly add or remove the configuration files.

```
$ fluentd-server sync
```

Or, you may just wait `SYNC_INTERVAL` senconds until a synchronization worker automatically synchronizes the information.
Please note that modifying the file content does not require to synchronize because the content is read from the local file directly.

NOTE: Enabling this feature disables to edit the Fluentd configuration from the Web UI.

### CLI (Command Line Interface)

Here is a full list of fluentd-server commands.

```bash
$ fluentd-server help
Commands:
  fluentd-server help [COMMAND]        # Describe available commands or one specific command
  fluentd-server init                  # Creates database schema
  fluentd-server job-clean             # Clean fluentd_server delayed_job queue
  fluentd-server job-worker            # Sartup fluentd_server job worker
  fluentd-server migrate               # Migrate database schema
  fluentd-server new                   # Creates fluentd-server resource directory
  fluentd-server start                 # Sartup fluentd_server
  fluentd-server sync                  # Synchronize local file storage with db immediately
  fluentd-server sync-worker           # Sartup fluentd_server sync worker
  fluentd-server td-agent-condrestart  # Run `/etc/init.d/td-agent condrestart` via serf event
  fluentd-server td-agent-configtest   # Run `/etc/init.d/td-agent configtest` via serf query
  fluentd-server td-agent-reload       # Run `/etc/init.d/td-agent reload` via serf event
  fluentd-server td-agent-restart      # Run `/etc/init.d/td-agent restart` via serf event
  fluentd-server td-agent-start        # Run `/etc/init.d/td-agent start` via serf event
  fluentd-server td-agent-status       # Run `/etc/init.d/td-agent status` via serf query
  fluentd-server td-agent-stop         # Run `/etc/init.d/td-agent stop` via serf event
```

## ToDo

* Automatic deployment (restart) support like the one of chef-server

## ChangeLog

See [CHANGELOG.md](CHANGELOG.md) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2014 Naotoshi Seo. See [LICENSE](LICENSE) for details.
