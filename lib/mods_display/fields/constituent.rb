module ModsDisplay
  class Constituent < Field
    def fields
      return_fields = @values.map do |value|
        next unless related_item_is_a_constituent?(value)
        process_constituent value
      end.compact
      collapse_fields(return_fields)
    end

    private

    def process_constituent(item)
      ModsDisplay::Values.new(label: constituent_label(item), values: [constituent_title(item)])
    end

    def constituent_title(item)
      titleInfo = item.at_xpath('titleInfo[not(@type)]') # remove alternatives
      [titleInfo.title,
       titleInfo.partNumber].flatten.compact.map!(&:text).map!(&:strip).join(', ')
    end

    def related_item_is_a_constituent?(item)
      item.attributes['type'].respond_to?(:value) &&
      item.attributes['type'].value == 'constituent'
    end

    def constituent_label(item)
      return displayLabel(item) if displayLabel(item)
      I18n.t('mods_display.constituent')
    end
  end
end
