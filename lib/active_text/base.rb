module ActiveText
  class Base
    attr_reader :text, :variables
    attr_writer :options

    def initialize(text, options={})
      @text = text
      @variables = {}

      options[:eol] ||= '\n'
      options[:context_lines] ||= 3
      options[:comment] ||= /\/\//
      options[:context] ||= "(^(?:#{options[:comment]}\s@.*#{options[:eol]}){#{options[:context_lines]}})"
      @options = options

      # instantiate all variables
      if @text
        @text.scan(/^\${1}(.+): .+;/).flatten.each do |variable_name|
          if has_context?(variable_name)
            variable = ActiveText::Variable.new(variable_name, context_of(variable_name), @options[:comment])
            @variables.merge!({variable_name.to_sym => variable})
          end
        end
      end
    end

    def update_attributes(args)
      args.each do |k, v|
        send "#{k.to_s}=", v
      end
    end

    # Used to update the text
    def render
      @variables.each do |key, var|
        @text.gsub!(/^\$#{key}: .+;/, %Q($#{key}: #{var.value};))
      end
      @text
    end

    def [](key)
      variable = @variables[key]
      {:name => variable.name, :description => variable.description, :value => variable.value, :kind => variable.kind}
    end

    def attributes
      h = {}
      @variables.each do |key, variable|
        h.merge!({key => variable.value})
      end
      h
    end

    protected

    # Whenever a variable is requested for, it falls into this.
    def method_missing(method_name, *args, &block)
      attr_key = method_name.to_s.sub(/\=$/, '').to_sym
      variable = @variables[attr_key]
      if variable
        if method_name.to_s =~ /\=$/
          value = args[0]
          variable.value = value unless value.nil?
        else
          variable.value
        end
      else
        raise NoMethodError, "Variable does not exist"
      end
    end

    # Works this way: http://rubular.com/r/jWSYvfVrjj
    # From http://rubular.com/r/jWSYvfVrjj
    # Derived from http://stackoverflow.com/questions/2760759/ruby-equivalent-to-grep-c-5-to-get-context-of-lines-around-the-match
    def context_of(s)
      regexp = /.*\${1}#{s}:.*;[#{@options[:eol]}]*/
      @text =~ /^#{@options[:context]}(#{regexp})/
      before, match = $1, $2
      "#{before}#{match}"
    end

    def has_context?(s)
      context = context_of(s)
      !(context.nil? || context == "")
    end
  end
end
