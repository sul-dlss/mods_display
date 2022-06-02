# frozen_string_literal: true

module ModsDisplay
  class RelatedItem < Field
    include ModsDisplay::RelatedItemConcerns

    def fields
      return_fields = @values.map do |value|
        next if related_item_is_a_collection?(value)
        next if render_nested_related_item?(value)

        text = related_item_value(value)

        next if text.nil? || text.empty?

        ModsDisplay::Values.new(label: related_item_label(value), values: [text])
      end.compact
      collapse_fields(return_fields)
    end

    private

    def delimiter
      '<br />'.html_safe
    end

    def related_item_value(item)
      if related_item_is_a_location?(item)
        element_text(item.location)
      elsif related_item_is_a_reference?(item)
        reference_title(item)
      elsif item.titleInfo.any?
        title = element_text(item.titleInfo)
        location = nil
        location = element_text(item.location.url) if item.location.length.positive? &&
                                                      item.location.url.length.positive?

        return if title.empty?

        if location
          "<a href='#{location}'>#{title}</a>".html_safe
        else
          title
        end
      elsif item.note.any?
        citation = item.note.find { |note| note['type'] == 'preferred citation' }

        element_text(citation) if citation
      end
    end

    def reference_title(item)
      [item.titleInfo,
       item.originInfo.dateOther,
       item.part.detail.number,
       item.note].flatten.compact.map!(&:text).map!(&:strip).join(' ')
    end

    def related_item_is_a_location?(item)
      !related_item_is_a_collection?(item) &&
        !related_item_is_a_reference?(item) &&
        item.location.length.positive? &&
        item.titleInfo.empty?
    end

    def related_item_is_a_reference?(item)
      !related_item_is_a_collection?(item) &&
        item.attributes['type'].respond_to?(:value) &&
        item.attributes['type'].value == 'isReferencedBy'
    end

    def related_item_label(item)
      if displayLabel(item)
        displayLabel(item)
      else
        case
        when related_item_is_a_location?(item)
          return I18n.t('mods_display.location')
        when related_item_is_a_reference?(item)
          return I18n.t('mods_display.referenced_by')
        end
        I18n.t('mods_display.related_item')
      end
    end
  end
end
