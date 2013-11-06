require 'json'
require 'rest_client'

module Hummer::Client::Model
  class Base
    def self.configure(options)
      @@server = RestClient::Resource.new(options[:server],
        :headers => {
          "X-User-ID" => options[:user],
          "X-User-Token" => options[:token],
          "Accept" => "application/json"
        }
      )
    end
    def self.resource res
      @resource = res
    end
    def self.attributes *args
      @attributes = []
      args.each do |arg|
        @attributes << arg
        self.class_eval("def #{arg};@#{arg};end")
        self.class_eval("def #{arg}=(val);@#{arg}=val;end")
      end
    end
    def self.find(id, resource = nil)
      new(JSON(@@server[resource || @resource][id].get))
    end
    def self.all(resource = nil)
      JSON(@@server[resource || @resource].get).collect do |params|
        new(params)
      end
    end
    def initialize(params = {})
      params.each do |key, value|
        send("#{key}=", value) if respond_to? "#{key}="
      end
    end
  end
end