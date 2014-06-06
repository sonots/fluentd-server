web: bundle exec unicorn -E production -p $PORT -o $HOST -c config/unicorn.conf
job: bundle exec bin/fluentd-server job
sync: bundle exec bin/fluentd-server sync
serf: $(bundle exec gem path serf-td-agent)/bin/serf agent
