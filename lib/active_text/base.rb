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
    end

    def update_attributes(args)
      args.each do |k, v|
        send(k) # Instantiate it, so it will exist in @variables
        @variables[k].value = v unless @variables[k].nil? || v.nil?
      end
    end

    # Used to update the text
    def render
      @variables.each do |key, var|
        @text.gsub!(/^\$#{key}: .+;/, %Q($#{key}: #{var.value};))
      end
      @text
    end

    protected

    # Whenever a variable is requested for, it falls into this.
    def method_missing(method_name)
      if method_name.to_s =~ /[\w]+/
        context = context_of(method_name)

        # If there's no context (no variable with the proper
        # commented metadata), then it should not be accessible
        # and it won't be accessible
        if context.nil? || context == ""
          nil
        else
          @variables[method_name] ||= ActiveText::Variable.new(method_name, context, @options[:comment])
        end
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
  end
end
