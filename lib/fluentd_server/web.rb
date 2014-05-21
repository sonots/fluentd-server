require 'sinatra'
require 'sinatra/flash'
require 'sinatra/redirect_with_flash'
require 'slim'

require 'fluentd_server'
require 'fluentd_server/config'
require 'fluentd_server/environment'
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
    @post = Post.find_by(id: params[:id])
    redirect "/" unless @post
    slim :"posts/edit"
  end

  post "/posts/:id" do
    @post = Post.find_by(id: params[:id])
    redirect "/" unless @post
    if @post.update(params[:post])
      redirect "/posts/#{@post.id}/edit", :notice => @post.decorate.success_message
    else
      redirect "/posts/#{@post.id}/edit", :error => @post.decorate.error_message
    end
  end

  # delete post
  post "/posts/:id/delete" do
    @post = Post.find_by(id: params[:id])
    if @post.destroy
      redirect "/", :notice => @post.decorate.success_message
    else
      redirect "/", :error => @post.decorate.error_message
    end
  end

  # get ALL posts in json
  get "/json/list" do
    @posts = Post.order("id ASC")
    content_type :json
    @posts.to_json
  end

  # get post in json
  get "/json/:name" do
    @post = Post.find_by(name: params[:name])
    return 404 unless @post
    content_type :json
    @post.to_json
  end

  # render api
  get "/api/:name" do
    @post = Post.find_by(name: params[:name])
    return 404 unless @post
    query_params = parse_query(request.query_string)
    content_type :text
    @post.decorate.render_body(query_params)
  end

  # job view
  get "/jobs" do
    slim :"jobs/index", layout: :"fluid"
  end

  # restart job
  post "/task/restart" do
    ::Task.new.restart
    redirect "/jobs", :notice => "`serf event td-agent-restart` issued"
  end

  # status job
  post "/task/status" do
    ::Task.new.status
    redirect "/jobs", :notice => "`serf query td-agent-status` issued"
  end
end
