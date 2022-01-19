module ModsDisplay
  class Title < Field
    def fields
      return_values = []
      if @values
        @values.each do |value|
          return_values << ModsDisplay::Values.new(
            label: displayLabel(value) || title_label(value),
            values: [assemble_title(value)]
          )
        end
      end
      collapse_fields(return_values)
    end

    private

    def delimiter
      '<br />'
    end

    def assemble_title(element)
      return displayForm(element) if displayForm(element)

      title = ''
      previous_element = nil

      element.children.select { |value| title_parts.include? value.name }.each do |value|
        str = value.text.strip
        next if str.empty?

        delimiter = case
        when title.empty?, title.end_with?(' ')
          nil
        when previous_element&.name == 'nonSort' && title.ends_with?('-', '\'')
          nil
        when title.end_with?('.', ',', ':', ';')
          ' '
        when value.name == 'subTitle'
          ' : '
        when value.name == 'partName' && previous_element.name == 'partNumber'
          ', '
        when value.name == 'partNumber', value.name == 'partName'
          '. '
        else
          ' '
        end

        title += delimiter if delimiter
        title += str

        previous_element = value
      end

      title
    end

    def title_parts
      %w[nonSort title subTitle partName partNumber]
    end

    def title_label(element)
      if element.attributes['type'].respond_to?(:value) &&
         title_labels.key?(element.attributes['type'].value)
        return title_labels[element.attributes['type'].value]
      end
      I18n.t('mods_display.title')
    end

    def title_labels
      { 'abbreviated' => I18n.t('mods_display.abbreviated_title'),
        'translated'  => I18n.t('mods_display.translated_title'),
        'alternative' => I18n.t('mods_display.alternative_title'),
        'uniform'     => I18n.t('mods_display.uniform_title') }
    end
  end
end
