require 'ostruct'
require 'fileutils'
require "maprename/mapping_parser"
require "maprename/content_parser"
require "maprename/file_name_parser"

module Maprename
  class Renamer
    def initialize(file, config)
      @context = OpenStruct.new
      @file = file
      @config = config

      parse_config!
    end

    def parse_config!
      @config[:input][:name_parse].try do |parse_config|
        Maprename::FileNameParser.new(parse_config).parse!(input_basename, @context)
      end

      @config[:input][:content_parse].try do |parse_config|
        Maprename::ContentParser.new(parse_config, @file).parse!(@context)
      end

      @config[:mapping].try do |mapping_config|
        Maprename::MappingParser.new(mapping_config).parse!(@context)
      end
    end

    def rename!(dry)
      if dry
        puts "mkdir -p %s" % File.dirname(destination)
        puts "cp %s %s" % [source, destination]
      else
        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.copy_file(source, destination)
      end
    end

    def input_dirname
      File.dirname(@file)
    end

    def input_basename
      File.basename(@file)
    end

    def source
      md = input_basename.match(Regexp.new(@config[:input][:pattern])).to_a
      File.join(input_dirname, @config[:input][:source].gsub(/\$(\d+)/) { md[$1.to_i] })
    end

    def destination
      File.join(@config[:output][:directory], @context.instance_eval('"%s"' % @config[:output][:filename]))
    end
  end
end
