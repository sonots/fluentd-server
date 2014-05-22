require 'sinatra/decorator'
require 'fluentd_server/web_helper'

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

class TaskDecorator < Sinatra::Decorator::Base
  include FluentdServer::WebHelper

  def link_to
    %Q[<a href="#{h("/tasks/#{self.id}")}">
      <span class="label label-success">&nbsp;</span> ##{h(self.id)} #{h(self.name)}
    </a>]
  end
end
