require 'fluentd_server/config'
require 'fluentd_server/model'

unless FluentdServer::Config.test_database_url.start_with?('file')
  describe Post do
    it { expect(Post.superclass).to eql(ActiveRecord::Base) }
  end
end
