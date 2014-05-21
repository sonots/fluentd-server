web: bundle exec unicorn -E production -p $PORT -o $HOST -c config/unicorn.conf
worker: bundle exec bin/fluentd-server worker
serf: $(bundle exec gem path serf-td-agent)/bin/serf agent
