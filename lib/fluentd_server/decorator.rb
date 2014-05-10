require 'sinatra/decorator'

class PostDecorator < Sinatra::Decorator::Base
  include Rack::Utils

  def success_message
    'Success!'
  end

  def error_message
    message = 'Failure! '
    message += self.errors.map {|key, msg| escape_html("`#{key}` #{msg}") }.join('. ')
    message
  end

  def render_body(locals)
    namespace = OpenStruct.new(locals)
    ERB.new(self.body, nil, "-").result(namespace.instance_eval { binding })
  end
end

