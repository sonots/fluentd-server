require 'sinatra/activerecord'
require 'sinatra/decorator'

class Post < ActiveRecord::Base
  include Sinatra::Decorator::Decoratable

  validates :name, presence: true
  validates :body, presence: true
end
