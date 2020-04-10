module Maprename
  class MappingParser

    attr_accessor :config

    def initialize(config)
      debug "  FileNameParser: #@config"
      @config = config
      @content = build_content
    end

    def parse!(context)
      @config[:select].each do |field_definition|
        debug "  MappingParser field definition: #{field_definition}"
        keyword_value = context.instance_eval(field_definition[:keyword_value])
        debug "  MappingParser keyword value: #{keyword_value}"
        row = @content.find { |row| row[field_definition[:keyword_column]] == keyword_value }
        debug "  MappingParser selected row: #{row}"
        context.instance_eval("self.%s = %s" % [field_definition[:name], row[field_definition[:select_column]].inspect])
        debug "  MappingParser context: #{context}"
      end
    end

    def build_content
      encoding = config[:encoding] || 'UTF-8'
      separator = config[:column_separator] || "\t"
      content = IO.readlines(config[:file], encoding: encoding).map { |l| l.chomp.encode('UTF-8') }
      debug "  MappingParser total mapping lines: #{content.size}"
      if config[:first_line_as_column_defination]
        config[:columns] = content.first.split(separator).each_with_index.map do |(c, i)|
          {
            name: c,
            index: i+1
          }
        end
      end

      debug "  MappingParser columns: #{config[:columns]}"

      content.map do |raw_row|
        fields = raw_row.split(separator)
        config[:columns].each_with_object({}) do |column, result|
          result[column[:name]] = fields[column[:index] - 1]
        end
      end
    end
  end
end
