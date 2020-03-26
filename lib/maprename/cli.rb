require 'optparse'
require 'maprename/app'

module Maprename
  class Cli
    def initialize
      @options = {}
      parse_options!
    end

    def parse_options!
      @raw_options = OptionParser.new do |opts|
        opts.banner = "Usage: maprename [options]"

        opts.on("-c", "--config CONFIG_FILE", "Specify config file, default to maprename.yml in current directory, see specification: https://github.com/lululau/maprename/blob/master/README.md") do |config|
          @options[:config] = config
        end

        opts.on("-d", "--dry", "dry run") do
          @options[:dry] = true
        end

        opts.on("-h", "--help", "Prints this help") do
          puts opts
          exit
        end
      end

      @raw_options.parse!
    end

    def config_file
      @options[:config] || "maprename.yml"
    end

    def run!
      config = config_file
      unless File.exists?(config)
        puts @raw_options
        exit 1
      end
      Maprename::App.new(config_file).run!(@options[:dry])
    end
  end
end
