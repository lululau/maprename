module Maprename
  class ContentParser

    attr_accessor :config

    def initialize(config, file)
      @config = config
      @file = file
      @content = read_file_content(file)

      debug "  ContentParser: #@config"
    end

    def parse!(context)
      config[:fields].each do |field_definition|
        debug "      ContentParser field definition: #{field_definition}"
        fields = @content.match(Regexp.new(field_definition[:pattern])).to_a[1..-1]
        debug "      ContentParser fields: #{fields}"
        eval_var_definition(fields, field_definition, context)
      end
    end

    def eval_var_definition(fields, field_definition, context)
      value = field_definition[:value].gsub(/\$(\d+)/, fields[$1.to_i - 1])
      context.instance_eval "self.#{field_definition[:name]} = #{value.inspect}"
      debug "      ContentParser value: #{value}"
      debug "      ContentParser context: #{context}"
    end

    def read_file_content(file)
      encoding = config[:encoding] || 'UTF-8'
      content = IO.read(file, encoding: '%s:UTF-8' % encoding)
      if config[:pre_processor]
        IO.popen(config[:pre_processor]) do |pipe|
          pipe.write(content)
          pipe.close_write
          pipe.read
        end
      else
        content
      end
    end
  end
end
