require 'optparse'
require 'net/http'
require 'yaml'

module Hummer::Client
  class Command
    def initialize(config = nil)
      @options = {}
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
        opts.banner = "Usage: hummer [options] <command>"
        opts.separator ""
        opts.separator "Specific commands:"
        opts.separator "\tlist"
        opts.separator "\tshow"
        opts.separator "\tpost"
        opts.separator ""
        opts.separator "Specific options:"
        opts.on(nil, '--help', 'Display help' ) do
          @options[:help] = true
        end
        opts.on(nil, '--user ID', 'User ID' ) do |id|
          puts user
          @options[:user] = id
        end
        opts.on(nil, '--token ID', 'User token' ) do |id|
          @options[:token] = id
        end
        opts.on(nil, '--server', 'Server url' ) do |url|
          @options[:server] = url
        end
        opts.on(nil, '--project', 'Project ID' ) do |id|
          @options[:project] = id
        end
        opts.on(nil, '--suite', 'Suite ID' ) do |id|
          @options[:suite] = id
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
      puts @options.inspect
    end
  end
end