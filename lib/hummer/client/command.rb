require 'terminal-table'
require 'optparse'
require 'yaml'
require 'readline'

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
        opts.banner = "Usage: hummer [options] [command]"
        opts.separator ""
        opts.separator "Specific commands: projects suites post"
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
        opts.on('--json', 'Output in JSON format' ) do
          @options[:json] = true
        end
        opts.on('--file FILE', 'XML file with test results') do |file|
          @options[:file] = file
        end
      end
      begin
        parser.parse ARGV
        if @options[:help] or ARGV.empty?
          puts parser
          exit(0)
        end
      rescue => e
        puts e.message
      end
    end
    def run
      API.configure(@options)
      command = ARGV.first
      if "projects" == command
        @projects = API.get()
        puts @projects.inspect
        if @projects.kind_of?(Hash) and @projects.has_key?("error")
          puts @projects["error"]
          exit(1)
        end
        if @options[:json]
          puts @projects.inspect
        else
          rows = []
          rows << ["ID","Name","Features","Owner"]
          rows << :separator
          @projects.each do |project|
            rows << [project["id"],project["name"],project["feature_list"].join(", "),project["owner_name"]]
          end
          table = Terminal::Table.new :rows => rows
          puts table
        end
      elsif "post" == command
        if @options[:project] and @options[:file]
          API.post(@options[:project], @options[:file], Readline.readline('Build: '), Readline.readline('Tags: '))
        else
          puts "Need project and file"
        end
      elsif "upload" == command
        if @options.has_key?(:project) and @options.has_key?(:file)
          @suite = API.post(@options[:project], @options[:file])
        else
          puts "Need project and file"
          exit(1)
        end

      elsif "suites" == command
        if @options.has_key?(:project)
          @suites = API.get(:project => @options[:project], :suite => nil)
          if @suites.kind_of?(Hash) and @suites.has_key?("error")
            puts @projects["error"]
            exit(1)
          end
          if @options[:json]
            puts @suites.inspect
          else
            rows = []
            rows << ["ID","Build","Tests","Errors","Failures","Skip","Passed","Features","Owner"]
            rows << :separator
            @suites.each do |suite|
              rows << [suite["id"],suite["build"],suite["total_tests"],suite["total_errors"],suite["total_failures"],suite["total_skip"],suite["total_passed"],suite["feature_list"].join(", "),suite["user_name"]]
            end
            table = Terminal::Table.new :rows => rows
            puts table
          end
        else
          puts "Need project"
          exit(1)
        end
      end
    end
  end
end
