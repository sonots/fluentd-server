require 'sinatra'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'slim'

require 'fluentd_server/config'
require 'fluentd_server/environments'
require 'fluentd_server/model'
require 'fluentd_server/decorator'
require 'fluentd_server/logger'
require 'fluentd_server/web_helper'

class FluentdServer::Web < Sinatra::Base
  include FluentdServer::Logger
  helpers FluentdServer::WebHelper

  set :dump_errors, true
  set :public_folder, File.join(__dir__, '..', '..', 'public')
  set :views,         File.join(__dir__, '..', '..', 'views')

  enable :sessions
  register Sinatra::Flash
  helpers Sinatra::RedirectWithFlash
  register Sinatra::ActiveRecordExtension

  # get ALL posts
  get "/" do
    @posts = Post.order("name ASC")
    slim :"posts/index"
  end

  # create new post
  get "/posts/create" do
    @tab = 'create'
    @title = 'Create'
    @post = Post.new
    slim :"posts/create"
  end

  post "/posts" do
    @post = Post.new(params[:post])
    if @post.save
      redirect "posts/#{@post.id}/edit", :notice => @post.decorate.success_message
    else
      redirect "posts/create", :error => @post.decorate.error_message
    end
  end

  # edit post
  get "/posts/:id/edit" do
    @title = 'Edit'
    @post = Post.find(params[:id])
    slim :"posts/edit"
  end

  post "/posts/:id" do
    @post = Post.find(params[:id])
    if @post.update(params[:post])
      redirect "/posts/#{@post.id}/edit", :notice => @post.decorate.success_message
    else
      redirect "/posts/#{@post.id}/edit", :error => @post.decorate.error_message
    end
  end

  # list all posts
  get "/json/list" do
    @posts = Post.order("name ASC")
    content_type :json
    @posts.to_json
  end

  # get post
  get "/json/:name" do
    @post = Post.find_by(name: params[:name])
    content_type :json
    @post.to_json
  end

  # render erb body
  get "/api/:name" do
    @post = Post.find_by(name: params[:name])
    query_params = parse_query(request.query_string)
    content_type :text
    @post.decorate.render_body(query_params)
  end
end
