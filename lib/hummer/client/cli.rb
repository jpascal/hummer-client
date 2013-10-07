require 'optparse'
require 'net/http'
require 'yaml'

module Hummer::Client
  DEFAULTS = {
      :server => {
          "url" => "http://0.0.0.0:9292"
      }
  }
  def self.configuration
    return @configuration if @configuration
    config = YAML.load_file("hummer.yml")
    config ||= {"server" => {}}
    @configuration = DEFAULTS[:server].merge(config["server"])
  end

  def self.connection
    return @connection if defined? @connection
    uri = URI.parse(configuration["url"])
    @connection = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == "https"
      @connection.use_ssl = true
      @connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    return @connection
  end

  def self.request type, options = {}
    path = options[:path] || {}
    query = options[:query] || {}
    params = options[:params] || {}
    case type
      when :get,:delete then
        response = connection.send(type,[path,query].join("?"))
      when :put,:post then
        response = connection.send(type, [path,query].join("?"), JSON.generate(params))
      else
        raise RuntimeError.new("unknown request type '#{type}'")
    end
    response
    #case response.code.to_i
    #  when 200,202 then
    #    begin
    #      response = JSON.parse(response.body)
    #    rescue JSON::ParserError
    #      raise OATClient::Exception.new(response.body)
    #    end
    #    raise OATClient::Exception.new("[#{response["error_code"]}] #{response["error_message"]}")
    #  end
    #end
  end

  class CLI
    def initialize
      @options = {}
      parser = OptionParser.new do|opts|
        opts.on( '-h', '--help', 'Display help' ) do
          @options[:help] = true
        end
      end
      begin
        parser.parse ARGV
        if @options[:help] or ARGV.empty?
          puts parser
        end
      rescue => e
        puts e.message
      end
    end
    def run
      puts Hummer::Client.configuration

    end
  end
end