class ModsDisplay::Field
  def initialize(value, config, klass)
    @value = value
    @config = config
    @klass = klass
  end

  def fields
    @value.map do |val|
      ModsDisplay::Values.new(:label => displayLabel(val) || label, :values => [text || val.text].flatten)
    end
  end

  def label
    return nil if @value.nil?
    displayLabel(@value.first)
  end

  def text
    return nil if @value.nil?
    if displayForm(@value)
      displayForm(@value).text
    end
  end

  def to_html
    return nil if fields.empty?
    output = ""
    fields.each do |field|
      if field.values.any?{|f| !f.empty? }
        output << "<dt#{label_class} title='#{field.label}'>#{field.label}:</dt>"
        output << "<dd#{value_class}>"
          output << field.values.map do |val|
            @config.link ? link_to_value(val.to_s) : val.to_s
          end.join(@config.delimiter)
        output << "</dd>"
      end
    end
    output
  end

  private

  def label_class
    " class='#{@config.label_class}'" unless @config.label_class == ""
  end

  def value_class
    " class='#{@config.value_class}'" unless @config.value_class == ""
  end

  def link_to_value(link_text, link_href=nil)
    "<a href='#{@klass.send(@config.link[0], replace_tokens(@config.link[1], link_href || link_text))}'>#{link_text}</a>"
  end

  def displayForm(element)
    element.children.find{|c| c.name == "displayForm"}
  end

  def displayLabel(element)
    if (element.respond_to?(:attributes) and
        element.attributes["displayLabel"].respond_to?(:value))
      element.attributes["displayLabel"].value
    end
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