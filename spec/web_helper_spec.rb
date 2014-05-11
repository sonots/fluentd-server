require_relative 'spec_helper'
require 'fluentd_server/web_helper'

describe 'WebHelper' do
  include FluentdServer::WebHelper

  context '#parse_query' do
    it 'key=val' do
      expect(parse_query('key=val')).to eql({'key'=>'val'})
    end

    it 'array' do
      # Array support of Rack::Utils.parse_query is as
      # `key=1&key=2` #=> key => ['1', '2']
      # But, I change it as `key[]=1&key[]=2` referring PHP
      expect(parse_query('key[]=1&key[]=2')).to eql({'key'=>['1','2']})
    end

    it 'hash' do
      expect(parse_query('name[key1]=1&name[key2]=2')).to eql(
        {'name' => {'key1'=>'1', 'key2'=>'2'}}
      )
    end
  end
end


