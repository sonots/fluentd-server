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

### DATA_DIR (experimental)

Configure `DATA_DIR` in `.env` file as:

```
DATA_DIR=data
```

to store and load Fluentd config contents not from DB, but from local files located at the directory `DATA_DIR`.
This would be useful when you want to manage your config files with git. 

## HTTP API

See [API.md](API.md).

## ToDo

* Create a sync worker to synchronize local file existences with db (delete and create entries on db). 
* Refresh the task result view progressively using ajax for serf query td-agent-status
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
