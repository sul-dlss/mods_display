module ModsDisplay
  class Contents < Field
    def to_html
      return nil if fields.empty? || @config.ignore?
      output = ''
      fields.each do |field|
        next unless field.values.any? { |f| f && !f.empty? }
        output << "<dt#{label_class} #{sanitized_field_title(field.label)}>#{field.label}</dt>"
        output << "<dd#{value_class}>"
        output << '<ul><li>'
        # compress all values into a "--"-delimited string then split them up
        output << field.values.join('--').split('--').map(&:strip).map do |val|
          @config.link ? link_to_value(val.to_s) : link_urls_and_email(val.to_s)
        end.join('</li><li>')
        output << '</li></ul>'
        output << '</dd>'
      end
      output
    end

    private

    def displayLabel(element)
      super(element) || I18n.t('mods_display.table_of_contents')
    end
  end
end
