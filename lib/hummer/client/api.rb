require 'json'

module Hummer::Client
  class API
    def self.configure(options)
      @options = options
      @headers = {}
      @headers["X-User-ID"] = @options[:user]
      @headers["X-User-Token"] = @options[:token]
      uri = URI(@options[:server])
      @server = Net::HTTP.new(uri.host, uri.port)
    end
    def self.get(options = {})
      if options.has_key?(:project) and options.has_key?(:suite)
        JSON @server.get("/api/projects/#{options[:project]}/suites/#{options[:suite]}",@headers).response.body
      elsif options.has_key?(:project)
        JSON @server.get("/api/projects/#{options[:project]}",@headers).response.body
      else
        JSON @server.get("/api/projects",@headers).response.body
      end
    end
    def self.post(project,file)

    end
  end
end