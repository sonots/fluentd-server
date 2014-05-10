require 'sinatra/activerecord'
require 'sinatra/decorator'

class Post < ActiveRecord::Base
  include Sinatra::Decorator::Decoratable

  validates :title, presence: true
  validates :body, presence: true
end
