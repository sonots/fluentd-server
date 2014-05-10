require 'cgi'

module FluentdServer::WebHelper
  include Rack::Utils
  alias_method :h, :escape_html

  def url_for(url_fragment, mode=nil, options = nil)
    if mode.is_a? Hash
      options = mode
      mode = nil
    end

    if mode.nil?
      mode = :path_only
    end

    mode = mode.to_sym unless mode.is_a? Symbol
    optstring = nil

    if options.is_a? Hash
      optstring = '?' + options.map { |k,v| "#{k}=#{URI.escape(v.to_s, /[^#{URI::PATTERN::UNRESERVED}]/)}" }.join('&')
    end

    case mode
    when :path_only
      base = request.script_name
    when :full
      scheme = request.scheme
      if (scheme == 'http' && request.port == 80 ||
          scheme == 'https' && request.port == 443)
        port = ""
      else
        port = ":#{request.port}"
      end
      base = "#{scheme}://#{request.host}#{port}#{request.script_name}"
    else
      raise TypeError, "Unknown url_for mode #{mode.inspect}"
    end
    "#{base}#{url_fragment}#{optstring}"
  end

  def escape_url(str)
    CGI.escape(str)
  end

  def title
    @title || 'Fluentd Server'
  end

  def tab
    @tab || 'welcome'
  end

  def active(_tab)
    if tab == _tab
      'active'
    else
      ''
    end
  end
end
