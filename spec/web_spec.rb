require_relative 'spec_helper'
require 'fluentd_server/web'
require 'capybara'
require 'capybara/dsl'
require 'paper_trail'
require 'timecop'

Capybara.app = FluentdServer::Web

describe 'Post' do
  include Capybara::DSL
  after { Post.delete_all }

  context 'get ALL posts' do
    it 'visit' do
      visit '/'
      expect(page.status_code).to be == 200
    end
  end

  context 'create new post' do
    before { visit '/posts/create' }

    it 'visit' do
      expect(page.status_code).to be == 200
    end

    it 'create' do
      expect {
        fill_in "post[name]", with: 'aaaa'
        fill_in "post[body]", with: 'aaaa'
        click_button('Submit')
      }.to change(Post, :count).by(1)
    end

    it 'fails to create' do
      expect {
        fill_in "post[name]", with: ''
        fill_in "post[body]", with: ''
        click_button('Submit')
      }.to change(Post, :count).by(0)
    end
  end
  
  context 'edit post' do
    before { Post.create(name: 'aaaa', body: 'aaaa') }
    let(:post) { Post.first }
    before { visit "/posts/#{post.id}/edit" }

    it 'visit' do
      expect(page.status_code).to be == 200
    end

    it 'edit' do
      fill_in "post[name]", with: 'bbbb'
      fill_in "post[body]", with: 'bbbb'
      click_button('Submit')
      edit = Post.find(post.id)
      expect(edit.name).to eql('bbbb')
      expect(edit.body).to eql('bbbb')
    end

    it 'fails to edit' do
      fill_in "post[name]", with: ''
      fill_in "post[body]", with: ''
      click_button('Submit')
      edit = Post.find(post.id)
      expect(edit.name).not_to eql('')
      expect(edit.body).not_to eql('')
    end

    # javascript click for `Really?` is required
    #it 'delete' do
    #  click_link('Delete')
    #  expect{Post.find(post.id)}.to raise_error
    #end
  end

  context 'delete post' do
    include Rack::Test::Methods

    def app
      FluentdServer::Web
    end

    before { Post.create(name: 'aaaa', body: '<%= key %>') }
    let(:subject) { Post.first }

    it 'delete' do
      post "/posts/#{subject.id}/delete"
      expect(Post.find_by(id: subject.id)).to be_nil
    end
  end
end

describe 'Task' do
  include Capybara::DSL
  after { Post.delete_all }

  context 'list tasks' do
    it 'visit' do
      visit '/tasks'
      expect(page.status_code).to be == 200
    end
  end

  context 'show task' do
    before { @task = Task.create }
    it 'visit' do
      visit "/tasks/#{@task.id}"
      expect(page.status_code).to be == 200
    end
  end

  context '/json/tasks/:id/body' do
    include Rack::Test::Methods
    def app; FluentdServer::Web; end

    before { @task = Task.create }
    it 'visit' do
      get "/json/tasks/#{@task.id}/body"
      expect(last_response.status).to eql(200)
      body = JSON.parse(last_response.body)
      expect(body).to be_has_key('body')
      expect(body).to be_has_key('bytes')
      expect(body).to be_has_key('moreData')
    end
  end

  context 'task button' do
    include Rack::Test::Methods
    def app; FluentdServer::Web; end

    it 'restart' do
      expect {
        post "/task/restart"
      }.to change(Task, :count).by(1)
    end

    it 'status' do
      expect {
        post "/task/status"
      }.to change(Task, :count).by(1)
    end

    it 'configtest' do
      expect {
        post "/task/configtest"
      }.to change(Task, :count).by(1)
    end
  end
end

describe 'API' do
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

    if FluentdServer::Config.store_history
      it 'render by history' do
        with_versioning do
          timestamp = Timecop.freeze(Date.today - 10) do
            post.body = 'hoge'
            post.save
          end
        end
        get "/api/#{post.name}?key=value"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql('hoge')
        get "/api/#{post.name}/#{(Date.today - 20).to_time.to_i}?key=value"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql('value')
      end
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
