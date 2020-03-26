require 'yaml'
require 'active_support/all'
require "maprename/renamer"

module Maprename
  class App
    def initialize(config_file)
      @config = YAML.load(IO.read(config_file)).with_indifferent_access
    end

    def run!(dry = false)
      input_files.each do |file|
        file = File.join(@config[:input][:directory], file)
        Maprename::Renamer.new(file, @config).rename!(dry)
      end
    end

    def input_files
      Dir.children(@config[:input][:directory]).grep(Regexp.new(@config[:input][:pattern]))
    end
  end
end
