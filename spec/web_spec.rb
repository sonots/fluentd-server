require_relative 'spec_helper'
require 'fluentd_server/web'
require 'capybara'
require 'capybara/dsl'

Capybara.app = FluentdServer::Web

describe 'Web' do
  include Capybara::DSL
  after { Post.delete_all }

  context 'get ALL posts' do
    it 'visit' do
      visit '/'
      page.status_code.should == 200
    end
  end

  context 'create new post' do
    before { visit '/posts/create' }

    it 'visit' do
      page.status_code.should == 200
    end

    it 'create' do
      expect {
        fill_in "post[name]", with: 'aaaa'
        fill_in "post[body]", with: 'aaaa'
        click_button('Submit')
      }.to change(Post, :count).by(1)
    end
  end
  
  context 'edit post' do
    before { Post.create(name: 'aaaa', body: 'aaaa') }
    let(:post) { Post.first }
    before { visit "/posts/#{post.id}/edit" }

    it 'visit' do
      page.status_code.should == 200
    end

    it 'edit' do
      fill_in "post[name]", with: 'bbbb'
      fill_in "post[body]", with: 'bbbb'
      click_button('Submit')
      edit = Post.find(post.id)
      expect(edit.name).to eql('bbbb')
      expect(edit.body).to eql('bbbb')
    end
  end
end


