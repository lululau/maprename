module Maprename
  class MappingParser

    attr_accessor :config

    def initialize(config)
      @config = config
      @content = build_content
    end

    def parse!(context)
      @config[:select].each do |field_definition|
        keyword_value = context.instance_eval(field_definition[:keyword_value])
        row = @content.find { |row| row[field_definition[:keyword_column]] == keyword_value }
        context.instance_eval("self.%s = %s" % [field_definition[:name], row[field_definition[:select_column]].inspect])
      end
    end

    def build_content
      encoding = config[:encoding] || 'UTF-8'
      separator = config[:column_separator] || "\t"
      content = IO.readlines(config[:file], encoding: encoding).map(&:chomp)
      if config[:first_line_as_column_defination]
        config[:columns] = content.first.split(separator).each_with_index.map do |(c, i)|
          {
            name: c,
            index: i+1
          }
        end
      end

      content.map do |raw_row|
        fields = raw_row.split(separator)
        config[:columns].each_with_object({}) do |column, result|
          result[column[:name]] = fields[column[:index] - 1]
        end
      end
    end
  end
end
