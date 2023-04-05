# frozen_string_literal: true

module ModsDisplay
  class Title < Field
    def fields
      return_values = sorted_values.map do |value|
        ModsDisplay::Values.new(
          label: displayLabel(value) || title_label(value),
          values: [assemble_title(value)]
        )
      end
      collapse_fields(return_values)
    end

    private

    # If there is a node with usage="primary", then it should come first.
    def sorted_values
      Array(@values).sort_by { |node| node['usage'] == 'primary' ? 0 : 1 }
    end

    def delimiter
      '<br />'.html_safe
    end

    def assemble_title(element)
      title = ''
      previous_element = nil

      element.children.select { |value| title_parts.include? value.name }.each do |value|
        str = value.text.strip
        next if str.empty?

        delimiter = if title.empty? || title.end_with?(' ')
                      nil
                    elsif previous_element&.name == 'nonSort' && title.end_with?('-', '\'')
                      nil
                    elsif title.end_with?('.', ',', ':', ';')
                      ' '
                    elsif value.name == 'subTitle'
                      ' : '
                    elsif value.name == 'partName' && previous_element.name == 'partNumber'
                      ', '
                    elsif value.name == 'partNumber' || value.name == 'partName'
                      '. '
                    else
                      ' '
                    end

        title += delimiter if delimiter
        title += str

        previous_element = value
      end

      if element['type'] == 'uniform' && element['nameTitleGroup'].present?
        [uniform_title_name_part(element), title].compact.join('. ')
      else
        title
      end
    end

    def uniform_title_name_part(element)
      names = element.xpath("//m:name[@nameTitleGroup=\"#{element['nameTitleGroup']}\"]", **Mods::Record::NS_HASH)
      names = element.xpath("//name[@nameTitleGroup=\"#{element['nameTitleGroup']}\"]") if names.empty?

      ModsDisplay::Name.new(names).fields.first&.values&.first&.to_s
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
        'translated' => I18n.t('mods_display.translated_title'),
        'alternative' => I18n.t('mods_display.alternative_title'),
        'uniform' => I18n.t('mods_display.uniform_title') }
    end
  end
end
