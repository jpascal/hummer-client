require 'optparse'
require 'net/http'
require 'yaml'

module Hummer::Client
  class Command
    def initialize(config = nil)
      @options = {
          :server => "http://0.0.0.0:3000"
      }
      if config
        config = File.expand_path(config)
        unless File.exist? config
          puts "Config file not found: #{config}"
          exit(1)
        end
        @options = YAML.load_file config if File.exist? config
      else
        config = File.expand_path("~/.hummer")
        @options = YAML.load_file config if File.exist? config
      end
      @options = Hash[@options.map{|a| [a.first.to_sym, a.last]}]

      parser = OptionParser.new do|opts|
        opts.banner = "Usage: hummer [options]"
        opts.separator ""
        opts.separator "Specific options:"
        opts.on('--help', 'Display help' ) do
          @options[:help] = true
        end
        opts.on('--user ID', 'User ID' ) do |id|
          @options[:user] = id
        end
        opts.on('--token ID', 'User token' ) do |id|
          @options[:token] = id
        end
        opts.on('--server URL', 'Server URL' ) do |url|
          @options[:server] = url
        end
        opts.on('--project ID', 'Project ID' ) do |id|
          @options[:project] = id
        end
        opts.on('--suite ID', 'Suite ID' ) do |id|
          @options[:suite] = id
        end
        opts.on('--file FILE', 'XML file with test results') do |id|
          @options[:suite] = id
        end
      end
      begin
        parser.parse ARGV
        if @options[:help]
          puts parser
          exit(0)
        end
      rescue => e
        puts e.message
      end
    end
    def run
      API.configure(@options)
      puts "Projects"
      @projects = API.get()
      @projects.each do |project|
        puts "#{project["id"]} #{project["name"]}"
      end
      puts "Suites"
      @suites = API.get(:project => "a87439c4-0f29-4aeb-a8fc-a941ec534258", :suite => nil)
      @suites.each do |suite|
        puts "#{suite["id"]} #{suite["build"]}"
      end
      puts "Suite"
      @suite = API.get(:project => "a87439c4-0f29-4aeb-a8fc-a941ec534258", :suite => "1ee666e5-a9d9-491c-81d3-2e597915b197")
      puts "#{@suite["id"]} #{@suite["build"]}"
    end
  end
end