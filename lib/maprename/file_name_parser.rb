module Maprename
  class FileNameParser
    def initialize(config)
      @config = config
      debug "  FileNameParser: #@config"
    end

    def parse!(subject, context)
      debug "    FileNameParser parse subject: #{subject}"
      debug "    FileNameParser parse context: #{context}"
      fields = if split_method?
        subject.split(Regexp.new(@config[:pattern]))
      else
        subject.match(Regexp.new(@config[:pattern])).to_a[1..-1]
      end

      debug "    FileNameParser fields: #{fields}"
      @config[:fields].each do |field_definition|
        eval_var_definition(fields, field_definition, context)
      end
    end

    def eval_var_definition(fields, field_definition, context)
      debug "      FileNameParser field definition: #{field_definition}"
      debug "      FileNameParser context: #{context}"

      value = field_definition[:value].gsub(/\$(\d+)/) { fields[$1.to_i - 1] }
      context.instance_eval "self.#{field_definition[:name]} = #{value.inspect}"

      debug "      FileNameParser value: #{value}"
      debug "      FileNameParser context: #{context}"
      if parse_config = field_definition[:name_parse]
        Maprename::FileNameParser.new(parse_config).parse!(context.instance_eval(field_definition[:name]), context)
      end
    end

    def split_method?
      @config[:method] == 'split'
    end
  end
end
