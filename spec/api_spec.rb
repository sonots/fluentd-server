require_relative 'spec_helper'
require 'fluentd_server/web'
require 'rack/test'
require 'json'

describe 'Web' do
  include Rack::Test::Methods

  def app
    FluentdServer::Web
  end

  after { Post.delete_all }
  before { Post.create(name: 'aaaa', body: '<%= key %>') }
  let(:post) { Post.first }

  context 'render api' do
    it 'render' do
      get "/api/#{post.name}?key=value"
      expect(last_response.status).to eql(200)
      expect(last_response.body).to eql('value')
    end
  end

  context 'get ALL posts in json' do
    it 'get' do
      get "/json/list"
      body = JSON.parse(last_response.body)
      expect(body[0]["name"]).to eql('aaaa')
    end
  end

  context 'get post in json' do
    it 'get' do
      get "/json/#{post.name}"
      body = JSON.parse(last_response.body)
      expect(body["name"]).to eql('aaaa')
    end
  end
end


