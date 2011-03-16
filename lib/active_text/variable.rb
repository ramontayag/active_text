module ActiveText
  # These are currently the kinds of metadata that we can fetch
  # This should be configurable in the future (or remove it entirely)
  #METADATA = %w(name kind description)

  class Variable
    attr_reader :name, :context, :comment

    def initialize(name, context, comment)
      # What the name of this variable is
      @name = name

      # Text surrounding the variable, as determined by Base
      @context = context

      # What is considered a comment
      @comment = comment
    end

    # if any of the metadata string methods are called
    # then we return what the value is
    def method_missing(method_name)
      #if METADATA.include? method_name.to_s
        content_of(method_name.to_s)
      #end
    end

    def value
      @context.each do |string|
        string =~ /^\${1}#{@var}: (.+);/
        return $1 if $1
      end
    end

    def value=(val)
      @context.gsub!(/^\$#{@var}: .+;/, "$#{@var}: #{val};")
    end

    private

    def content_of(variable)
      @context.each do |string|
        string =~ /^#{@comment} @([\w]+[^\s]) (.+)/
        return $2 if $1 == variable
      end
    end

  end
end
