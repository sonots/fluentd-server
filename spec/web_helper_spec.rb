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

  context '#escape_url' do
    it { expect(escape_url('a b')).to eql('a+b') }
  end

  context '#active_if' do
    it { expect(active_if(true)).to eql('active') }
    it { expect(active_if(false)).to be_nil }
  end

  context '#disabled_if' do
    it { expect(disabled_if(true)).to eql('disabled="disabled"') }
    it { expect(disabled_if(false)).to be_nil }
  end

end


