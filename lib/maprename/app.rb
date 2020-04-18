require 'yaml'
require 'active_support/all'
require "maprename/renamer"

module Maprename
  class App
    def initialize(config_file)
      @config = YAML.load(IO.read(config_file)).with_indifferent_access
    end

    def run!(opts)
      input_files.each do |file|
        begin
        file = File.join(@config[:input][:directory], file)
        Maprename::Renamer.new(file, @config).rename!(opts[:dry])
        rescue => e
          STDERR.puts("Error occurs when processing file: #{file}, skipped")
          if $debug
            STDERR.puts "#{e.inspect}, #{e.backtrace}"
          end
        end
      end
    end

    def input_files
      files = Dir.children(@config[:input][:directory]).grep(Regexp.new(@config[:input][:pattern]))
      debug 'Matched input files:'
      debug files.map { |f| '  %s' % f}
      files
    end
  end
end
