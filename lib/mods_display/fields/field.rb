class ModsDisplay::Field
  def initialize(value, config, klass)
    @value = value
    @config = config
    @klass = klass
  end

  def label
    if @value.attributes["displayLabel"].respond_to?(:value)
      @value.attributes["displayLabel"].value
    end
  end

  def text
    if @value.respond_to?(:displayForm)
      @value.displayForm.text
    end
  end

  def to_html
    output = ""
    output << "<dt class='#{@config.label_class}'>#{label}:</dt>"
    output << "<dd class='#{@config.value_class}'>"
      if @config.link
        if text.is_a?(Array)
          text.each do |txt|
            output << "<a href='#{@klass.send(@config.link[0], replace_tokens(@config.link[1], txt))}'>#{txt}</a>"
          end
        else
          output << "<a href='#{@klass.send(@config.link[0], replace_tokens(@config.link[1], text))}'>#{text}</a>"
        end
      else
        output << text
      end
    output << "</dd>"
  end

  private

  def replace_tokens(object, value)
    object = object.dup
    if object.is_a?(Hash)
      object.each do |k,v|
        object[k] = replace_token(v, value)
      end
    elsif object.is_a?(String)
      object = replace_token(object, value)
    end
    object
  end

  def replace_token(string, value)
    string = string.dup
    tokens.each do |token|
      string.gsub!(token, value)
    end
    string
  end

  def tokens
    ["%value%"]
  end

end