# encoding: utf-8
module ModsDisplay
  class Field
    def initialize(values, config, klass)
      @values = values
      @config = config
      @klass = klass
    end

    def fields
      return_fields = @values.map do |value|
        ModsDisplay::Values.new(
          label: displayLabel(value) || label,
          values: [displayForm(@values) || value.text].flatten
        )
      end
      collapse_fields(return_fields)
    end

    def label
      return nil if @values.nil?
      displayLabel(@values.first)
    end

    def to_html
      return nil if fields.empty? || @config.ignore?
      output = ''
      fields.each do |field|
        next unless field.values.any? { |f| f && !f.empty? }
        output << "<dt#{label_class} #{sanitized_field_title(field.label)}>#{field.label}</dt>"
        output << "<dd#{value_class}>"
        output << field.values.map do |val|
          @config.link ? link_to_value(val.to_s) : link_urls_and_email(val.to_s)
        end.join(@config.delimiter)
        output << '</dd>'
      end
      output
    end

    private

    def compact_and_join_with_delimiter(values, delimiter)
      compact_values = values.compact.reject { |v| v.strip.empty? }
      return compact_values.join(delimiter) if compact_values.length == 1 ||
                                               !ends_in_terminating_punctuation?(delimiter)
      compact_values.each_with_index.map do |value, i|
        if (compact_values.length - 1) == i || # last item?
           ends_in_terminating_punctuation?(value)
          value << ' '
        else
          value << delimiter
        end
      end.join.strip
    end

    def process_bc_ad_dates(date_fields)
      date_fields.map do |date_field|
        case
        when date_is_bc_edtf?(date_field)
          year = date_field.text.strip.gsub(/^-0*/, '').to_i + 1
          date_field.content = "#{year} B.C."
        when date_is_ad?(date_field)
          date_field.content = "#{date_field.text.strip.gsub(/^0*/, '')} A.D."
        end
        date_field
      end
    end

    def date_is_bc_edtf?(date_field)
      date_field.text.strip.start_with?('-') && date_is_edtf?(date_field)
    end

    def date_is_ad?(date_field)
      date_field.text.strip.gsub(/^0*/, '').length < 4
    end

    def date_is_edtf?(date_field)
      field_is_encoded?(date_field, 'edtf')
    end

    def field_is_encoded?(field, encoding)
      field.attributes['encoding'] &&
        field.attributes['encoding'].respond_to?(:value) &&
        field.attributes['encoding'].value.downcase == encoding
    end

    def ends_in_terminating_punctuation?(value)
      value.strip.end_with?('.', ',', ':', ';')
    end

    def label_class
      " class='#{@config.label_class}'" unless @config.label_class == ''
    end

    def value_class
      " class='#{@config.value_class}'" unless @config.value_class == ''
    end

    def link_to_value(link_text, link_href = nil)
      href_or_text = link_href || link_text
      "<a href='#{@klass.send(@config.link[0], replace_tokens(@config.link[1], href_or_text))}'>#{link_text}</a>"
    end

    def displayForm(element)
      return element unless element # basically return nil
      display = element.children.find { |c| c.name == 'displayForm' }
      return display.text if display
    end

    def displayLabel(element)
      return unless element.respond_to?(:attributes) &&
                    element.attributes['displayLabel'].respond_to?(:value)
      "#{element.attributes['displayLabel'].value}:"
    end

    def sanitized_field_title(label)
      "title='#{label.gsub(/:$/, '').strip}'"
    end

    def replace_tokens(object, value)
      object = object.dup
      if object.is_a?(Hash)
        object.each do |k, v|
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
      ['%value%']
    end

    # rubocop:disable Metrics/LineLength
    # Disabling line length due to necessarily long regular expressions
    def link_urls_and_email(val)
      val = val.dup
      # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
      url = %r{(?i)\b(?:https?://|www\d{0,3}[.]|[a-z0-9.\-]+[.][a-z]{2,4}\/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])}i
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
    # rubocop:enable Metrics/LineLength

    def collapse_fields(display_fields)
      return display_fields if display_fields.length == 1

      display_fields.slice_when { |before, after| before.label != after.label }.map do |group|
        next group.first if group.length == 1

        ModsDisplay::Values.new(label: group.first.label, values: group.map(&:values).flatten)
      end
    end
  end
end
