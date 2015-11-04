class ModsDisplay::Title < ModsDisplay::Field
  def fields
    return_values = []
    if @values
      @values.each do |value|
        if displayForm(value)
          return_values << ModsDisplay::Values.new(label: displayLabel(value) || title_label(value), values: [displayForm(value)])
        else
          nonSort = nil
          title = nil
          subTitle = nil
          nonSort = value.nonSort.text.strip unless value.nonSort.text.strip.empty?
          title = value.title.text.strip unless value.title.text.strip.empty?
          subTitle = value.subTitle.text unless value.subTitle.text.strip.empty?
          preSubTitle = [nonSort, title].compact.join(' ')
          preSubTitle = nil if preSubTitle.strip.empty?
          preParts = [preSubTitle, subTitle].compact.join(' : ')
          preParts = nil if preParts.strip.empty?
          parts = value.children.select do |child|
            %w(partName partNumber).include?(child.name)
          end.map(&:text).compact.join(parts_delimiter(value))
          parts = nil if parts.strip.empty?
          return_values << ModsDisplay::Values.new(label: displayLabel(value) || title_label(value), values: [[preParts, parts].compact.join('. ')])
        end
      end
    end
    collapse_fields(return_values)
  end

  private

  def parts_delimiter(element)
    children = element.children.to_a
    # index will retun nil which is not comparable so we call 100 if the element isn't present (thus meaning it's at the end of the list)
    if (children.index { |c| c.name == 'partNumber' } || 100) < (children.index { |c| c.name == 'partName' } || 100)
      return ', '
    end
    '. '
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
