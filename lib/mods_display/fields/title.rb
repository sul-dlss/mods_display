# frozen_string_literal: true

module ModsDisplay
  class Title < Field
    def initialize(values, link: nil)
      @link = link
      super(values)
    end

    def fields
      return_values = sorted_title_info_elements.map do |title_info_element|
        ModsDisplay::Values.new(
          label: displayLabel(title_info_element) || title_label(title_info_element),
          values: [assemble_title(title_info_element)]
        )
      end
      collapse_fields(return_values)
    end

    private

    # If there is a node with usage="primary", then it should come first.
    def sorted_title_info_elements
      Array(@stanford_mods_elements).sort_by { |title_info_element| title_info_element['usage'] == 'primary' ? 0 : 1 }
    end

    def delimiter
      '<br />'.html_safe
    end

    def assemble_title(title_info_element)
      title = ''
      previous_element = nil

      title_info_element.children.select { |child| title_parts.include? child.name }.each do |child|
        text = child.text.strip
        next if text.empty?

        delimiter = title_delimiter(title, previous_element, child)

        title += delimiter if delimiter
        title += text

        previous_element = child
      end

      full_title = if title_info_element['type'] == 'uniform' && title_info_element['nameTitleGroup'].present?
                     [uniform_title_name_part(title_info_element), title].compact.join('. ')
                   else
                     title
                   end
      linked_title(full_title)
    end

    def title_delimiter(title, previous_element, child)
      if title.empty? || title.end_with?(' ')
        nil
      elsif previous_element&.name == 'nonSort' && title.end_with?('-', '\'')
        nil
      elsif title.end_with?('.', ',', ':', ';')
        ' '
      elsif child.name == 'subTitle'
        ' : '
      elsif child.name == 'partName' && previous_element.name == 'partNumber'
        ', '
      elsif child.name == 'partNumber' || child.name == 'partName'
        '. '
      else
        ' '
      end
    end

    def linked_title(title)
      return title unless @link

      "<a href=\"#{@link}\">#{title}</a>"
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
