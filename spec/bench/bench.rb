#!/usr/bin/env ruby
 
require 'parallel'
require 'net/http'

def main
  requests = 20000  # number of requests to perform
  concurrency = 126 # number of multiple requests to make
  name = 'worker'
  puts "requests = #{requests}"
  puts "concurrency = #{concurrency}"

  client = Client.new("http://localhost:5126")

  duration = elapsed_time do 
    Parallel.each_with_index([name]*requests, :in_processes => concurrency) do |name, i|
      puts "processing #{i}" if i % 1000 == 0
      res = client.get(name)
      puts 'error' unless res.code == '200'
    end
  end

  req_per_sec = ( duration > 0 ) ? requests/duration : 0
  puts "req/sec = #{req_per_sec}"
end

def elapsed_time(&block)
  s = Time.now
  yield
  Time.now - s 
end 

class Client
  attr_reader   :base_uri
  attr_reader   :host
  attr_reader   :port
  attr_accessor :debug_dev
  attr_accessor :open_timeout
  attr_accessor :read_timeout
  attr_accessor :verify_ssl
  attr_accessor :keepalive

  def initialize(base_uri = 'http://127.0.0.1:5126', opts = {})
    @base_uri = base_uri

    URI.parse(base_uri).tap {|uri|
      @host = uri.host
      @port = uri.port
      @use_ssl = uri.scheme == 'https'
    }
    @debug_dev    = opts['debug_dev'] # IO object such as STDOUT
    @open_timeout = opts['open_timeout'] # 60
    @read_timeout = opts['read_timeout'] # 60
    @verify_ssl   = opts['verify_ssl']
    @keepalive    = opts['keepalive']
  end

  def http_connection
    Net::HTTP.new(@host, @port).tap {|http|
      http.use_ssl      = @use_ssl
      http.open_timeout = @open_timeout if @open_timeout
      http.read_timeout = @read_timeout if @read_timeout
      http.verify_mode  = OpenSSL::SSL::VERIFY_NONE unless @verify_ssl
      http.set_debug_output(@debug_dev) if @debug_dev
    }
  end

  def get_request(path, extheader = {})
    Net::HTTP::Get.new(path).tap {|req|
      req['Host'] = @host
      req['Connection'] = 'Keep-Alive' if @keepalive
      extheader.each {|key, value| req[key] = value }
    }
  end

  def get(name)
    path = "/api/#{name}"
    req  = get_request(path)
    @res = http_connection.start {|http| http.request(req) }
  end
end

main
