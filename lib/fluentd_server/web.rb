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

  # create new post
  get %r{^/$|^/posts/create$} do
    @tab = 'posts'
    @posts = Post.order("name ASC")
    @post = Post.new
    slim :"posts/layout"
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
    @tab = 'posts'
    @post = Post.find_by(id: params[:id])
    redirect "/" unless @post
    @posts = Post.order("name ASC")
    slim :"posts/layout"
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
      redirect "/posts/create", :notice => @post.decorate.success_message
    else
      redirect "/posts/create", :error => @post.decorate.error_message
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

  # list task
  get "/tasks" do
    @tab = 'tasks'
    @tasks = Task.limit(20).order("id DESC")
    slim :"tasks/show"
  end

  # show task
  get "/tasks/:id" do
    @tab = 'tasks'
    @tasks = Task.limit(20).order("id DESC")
    @task = Task.find_by(id: params[:id])
    slim :"tasks/show"
  end

  # restart task
  post "/task/restart" do
    @task = ::Task.create(name: 'Restart')
    @task.restart
    redirect "/tasks/#{@task.id}"
  end

  # status task
  post "/task/status" do
    @task = ::Task.create(name: 'Status')
    @task.status
    redirect "/tasks/#{@task.id}"
  end

  # configtest task
  post "/task/configtest" do
    @task = ::Task.create(name: 'Configtest')
    @task.configtest
    redirect "/tasks/#{@task.id}"
  end

end
