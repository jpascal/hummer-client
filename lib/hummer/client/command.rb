require 'terminal-table'
require 'optparse'
require 'yaml'
require 'readline'

require 'hummer/client/model'

module Hummer::Client
  class Command
    include Hummer::Client::Model
    def initialize(config = nil)
      @options = {
        :server => "http://0.0.0.0:3000",
        :user => "00000000-0000-0000-0000-000000000000",
        :token => ""
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
        opts.separator "Commands: projects suites features post"
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
        opts.on('--features NAMEs', 'Feature name, separeted by \',\'' ) do |features|
          @options[:features] = features
        end
        opts.on('--build name', 'Build for new post' ) do |build|
          @options[:build] = build
        end
        opts.on('--json', 'Output in JSON format' ) do
          @options[:json] = true
        end
        opts.on('--file FILE', 'XML file with test results') do |file|
          @options[:file] = file
        end
        opts.on('--version', 'Display version') do
          @options[:version] = true
        end
      end
      begin
        parser.parse ARGV
        if @options[:version]
          puts "Version: #{Hummer::Client::VERSION}"
          exit(0)
        end
        if @options[:help] or ARGV.empty?
          puts parser
          exit(0)
        end
      rescue => e
        puts e.message
      end
    end
    def display(objects, titles)
      objects = objects.kind_of?(Array) ? objects : objects.to_a
      rows = []
      rows << titles.collect{|_,title| title }
      rows << :separator
      objects.each do |object|
        values = []
        titles.collect{|key,_| key}.each do |attribute|
          value = object.send(attribute)
          if value.kind_of?(Array)
            values << value.join(", ")
          else
            values << value
          end
        end
        rows << values
      end
      puts Terminal::Table.new :rows => rows
    end
    def run
      Base.configure(@options)
      command = ARGV.first
      case command
        when "features" then
          display Feature.all, [[:id,"ID"],[:name, "Name"]]
        when "projects" then
          display Project.all, [[:id,"ID"],[:name,"Name"],[:feature_list,"Features"],[:owner_name,"Owner"]]
        when "suites" then
          if @options[:project]
            project = Project.find(@options[:project])
            suites = project.suites
          else
            suites = Suite.all
          end
          display suites, [[:id,"ID"],[:build,"Build"],[:feature_list,"Features"],[:user_name,"User"],[:total_tests, "Tests"],[:total_errors, "Errors"],[:total_failures, "Failures"],[:total_skip,"Skip"],[:total_passed,"Passed"]]
        when "post" then
          project = @options[:project]
          unless project
            project = Readline.readline('Project> ')
            project = Project.find(project.strip)
          end
          build = @options[:build]
          unless build
            build = Readline.readline('Build> ')
          end
          features = @options[:features]
          unless features
            puts "Already exists features: #{Feature.all.collect{|f| f.name}.join(", ")}"
            puts "Default features: #{project.feature_list.join(", ")}"
            features = Readline.readline('Features> ')
          end
          file = @options[:file]
          unless file
            file = Readline.readline('File> ')
          end
          Suite.save(project.id, build, features, file)
        else
          puts "Unknown command: #{command}"
          exit(1)
      end
    end
  end
end
