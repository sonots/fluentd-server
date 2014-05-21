web: bundle exec unicorn -E production -p $PORT -o $HOST -c config/unicorn.conf
job: bundle exec bin/fluentd-server job
serf: $(bundle exec gem path serf-td-agent)/bin/serf agent
