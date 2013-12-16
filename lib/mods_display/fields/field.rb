# encoding: utf-8
class ModsDisplay::Field
  def initialize(values, config, klass)
    @values = values
    @config = config
    @klass = klass
  end

  def fields
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(:label => displayLabel(value) || label, :values => [displayForm(@values) || value.text].flatten)
    end
    collapse_fields(return_fields)
  end

  def label
    return nil if @values.nil?
    displayLabel(@values.first)
  end

  def to_html
    return nil if fields.empty? or @config.ignore?
    output = ""
    fields.each do |field|
      if field.values.any?{|f| f && !f.empty? }
        output << "<dt#{label_class} #{sanitized_field_title(field.label)}>#{field.label}</dt>"
        output << "<dd#{value_class}>"
          output << field.values.map do |val|
            @config.link ? link_to_value(val.to_s) : link_urls_and_email(val.to_s)
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
    return element unless element # basically return nil
    display = element.children.find{|c| c.name == "displayForm"}
    return display.text if display
  end

  def displayLabel(element)
    if (element.respond_to?(:attributes) and
        element.attributes["displayLabel"].respond_to?(:value))
      "#{element.attributes["displayLabel"].value}:"
    end
  end

  def sanitized_field_title(label)
    "title='#{label.gsub(/:$/,'').strip}'"
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

  def link_urls_and_email(val)
    val = val.dup
    # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
    url = /(?i)\b(?:https?:\/\/|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])/i
    # http://www.regular-expressions.info/email.html
    email = /[A-Z0-9_\.%\+\-\']+@(?:[A-Z0-9\-]+\.)+(?:[A-Z]{2,4}|museum|travel)/i
    matches = [val.scan(url), val.scan(email)].flatten
    unless val =~ /<a/ # we'll assume that linking has alraedy occured and we don't want to double link
      matches.each do |match|
        if match =~ email
          val = val.gsub(match, "<a href='mailto:#{match}'>#{match}</a>")
        else
          val = val.gsub(match, "<a href='#{match}'>#{match}</a>")
        end
      end
    end
    val
  end

  def collapse_fields(display_fields)
    return_values = []
    current_label = nil
    prev_label = nil
    buffer = []
    display_fields.each_with_index do |field, index|
      current_label = field.label
      current_values = field.values
      if display_fields.length == 1
        return_values << ModsDisplay::Values.new(:label => current_label, :values => current_values)
      elsif index == (display_fields.length-1)
        # need to deal w/ when we have a last element but we have separate labels in the buffer.
        if current_label != prev_label
          return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
          return_values << ModsDisplay::Values.new(:label => current_label, :values => current_values)
        else
          buffer.concat(current_values)
          return_values << ModsDisplay::Values.new(:label => current_label, :values => buffer.flatten)
        end
      elsif prev_label and (current_label != prev_label)
        return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
        buffer = []
      end
      buffer.concat(current_values)
      prev_label = current_label
    end
    return_values
  end

end