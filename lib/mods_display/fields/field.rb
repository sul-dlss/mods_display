class ModsDisplay::Field
  def initialize(value, config, klass)
    @value = value
    @config = config
    @klass = klass
  end

  def label
    return nil if @value.nil?
    if @value.attributes["displayLabel"].respond_to?(:value)
      @value.attributes["displayLabel"].value
    end
  end

  def text
    return nil if @value.nil?
    if displayForm(@value)
      displayForm(@value).text
    end
  end

  def to_html
    return nil if (@value.nil? or text.nil?)
    output = ""
    output << "<dt class='#{@config.label_class}'>#{label}:</dt>"
    output << "<dd class='#{@config.value_class}'>"
      if @config.link
        if text.is_a?(Array)
          links = []
          text.each do |txt|
            links << "<a href='#{@klass.send(@config.link[0], replace_tokens(@config.link[1], txt))}'>#{txt}</a>"
          end
          output << links.join(@config.delimiter)
        else
          output << "<a href='#{@klass.send(@config.link[0], replace_tokens(@config.link[1], text))}'>#{text}</a>"
        end
      else
        output << text
      end
    output << "</dd>"
  end

  private

  def displayForm(element)
    element.children.find{|c| c.name == "displayForm"}
  end

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