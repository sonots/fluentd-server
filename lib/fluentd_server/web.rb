require 'sinatra'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'slim'

require 'fluentd_server/config'
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
    @posts = Post.order("title ASC")
    slim :"posts/index"
  end

  # create new post
  get "/posts/create" do
    @title = "Create"
    @tab = 'create'
    @post = Post.new
    slim :"posts/create"
  end

  post "/posts" do
    @post = Post.new(params[:post])
    if @post.save
      redirect "posts/#{@post.id}", :notice => @post.decorate.success_message
    else
      redirect "posts/create", :error => @post.decorate.error_message
    end
  end

  # edit post
  get "/posts/:id/edit" do
    @post = Post.find_by(title: params[:id])
    @title = "Edit"
    slim :"posts/edit"
  end

  post "/posts/:id" do
    @post = Post.find(params[:id])
    if @post.update(params[:post])
      redirect "/posts/#{@post.id}", :notice => @post.decorate.success_message
    else
      redirect "/posts/#{@post.id}", :error => @post.decorate.error_message
    end
  end

  # list all posts
  get "/json/list" do
    @posts = Post.order("title ASC")
    content_type :json
    @posts.to_json
  end

  # get post
  get "/json/:title" do
    @post = Post.find_by(title: params[:title])
    content_type :json
    @post.to_json
  end

  # render erb body
  get "/api/:title" do
    @post = Post.find_by(title: params[:title])
    query_params = parse_query(request.query_string)
    content_type :text
    @post.decorate.render_body(query_params)
  end
end
