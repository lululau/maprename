module Maprename
  class FileNameParser
    def initialize(config)
      @config = config
    end

    def parse!(subject, context)
      fields = if split_method?
        subject.split(Regexp.new(@config[:pattern]))
      else
        subject.match(Regexp.new(@config[:pattern])).to_a[1..-1]
      end

      @config[:fields].each do |field_definition|
        eval_var_definition(fields, field_definition, context)
      end
    end

    def eval_var_definition(fields, field_definition, context)
      value = field_definition[:value].gsub(/\$(\d+)/) { fields[$1.to_i - 1] }
      context.instance_eval "self.#{field_definition[:name]} = #{value.inspect}"

      if parse_config = field_definition[:name_parse]
        Maprename::FileNameParser.new(parse_config).parse!(context.instance_eval(field_definition[:name]), context)
      end
    end

    def split_method?
      @config[:method] == 'split'
    end
  end
end
