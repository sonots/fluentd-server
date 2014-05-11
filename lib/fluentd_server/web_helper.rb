require 'cgi'
require 'fluentd_server'

module FluentdServer::WebHelper
  include Rack::Utils
  alias_method :h, :escape_html

  # override RackUtil.parse_query
  # @param qs query string
  # @param d delimiter
  # @return
  def parse_query(qs, d=nil)
    params = {}
    (qs || '').split(d ? /[#{d}] */n : DEFAULT_SEP).each do |p|
      k, v = p.split('=', 2).map { |x| unescape(x) }
      if k.ends_with?('[]')
        k1 = k[0..-3]
        if params[k1] and params[k1].class == Array
          params[k1] << v
        else
          params[k1] = [v]
        end
      elsif k.ends_with?(']') and md = k.match(/^([^\[]+)\[([^\]]+)\]$/)
        k1, k2 = md[1], md[2]
        if params[k1] and params[k1].class == Hash
          params[k1][k2] = v
        else
          params[k1] = { k2 => v }
        end
      else
        params[k] = v
      end
    end
    params
  end

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
    @title || 'Welcome'
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
