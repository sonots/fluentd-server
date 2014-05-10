## Fluentd Server

[![Build Status](https://secure.travis-ci.org/sonots/fluentd-server.png?branch=master)](http://travis-ci.org/sonots/fluentd-server)
[![Coverage Status](https://coveralls.io/repos/sonots/fluentd-server/badge.png?branch=master)](https://coveralls.io/r/sonots/fluentd-server?branch=master)

A Fluentd config distribution server

## Prerequisites

* SQLite

## Installation

Install with Ruby 2.0 or later. 

### Gem package

Five easy steps on installation with gem and SQLite.

```bash
$ gem install fluentd-server
$ fluentd-server new
$ cd fluentd-server
$ fluentd-server init # creates database scheme on SQLite
$ fluentd-server start
```

Then see `http://localhost:5126/`.

### Git repository

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
# DATA_DIR=data
# DATABASE_URL=sqlite3:data/fluentd_server.db
# LOG_PATH=log/application.log
# LOG_LEVEL=warn
```

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
