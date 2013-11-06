require 'json'
require 'net/http'
require 'rest_client'

module Hummer::Client
  class API
    def self.configure(options)
      @server = RestClient::Resource.new(options[:server],
        :headers => {
          "X-User-ID" => options[:user],
          "X-User-Token" => options[:token],
          "Accept" => "application/json"
        }
      )
    end
    def self.get(options = {})
      if options.has_key?(:project) and options.has_key?(:suite)
        JSON @server['projects'][options[:project]]['suites'][options[:suite]].get
      elsif options.has_key?(:project)
        JSON @server['projects'][options[:project]]['suites'].get
      else
        JSON @server['projects'].get
      end
    end
    def self.post(project,file,build,feature_list)
      JSON @server['projects'][project]['suites'].post :tempest => File.open(file), :build => build, :feature_list => feature_list
    end
  end
end