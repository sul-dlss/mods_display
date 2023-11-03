# frozen_string_literal: true

module ModsDisplay
  class RelatedItem < Field
    include ModsDisplay::RelatedItemConcerns

    def fields
      return_fields = RelatedItemValue.for_values(@values).map do |value|
        next if value.collection?
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
      if item.location?
        element_text(item.location_nodeset)
      elsif item.reference?
        reference_title(item)
      elsif item.titleInfo_nodeset.any?
        title = element_text(item.titleInfo_nodeset)
        location = nil
        location = element_text(item.location_url_nodeset) if item.location_url_nodeset.length.positive?

        return if title.empty?

        if location
          "<a href='#{location}'>#{title}</a>".html_safe
        else
          title
        end
      elsif item.note_nodeset.any?
        citation = item.note_nodeset.find { |note| note['type'] == 'preferred citation' }

        element_text(citation) if citation
      end
    end

    def reference_title(item)
      [item.titleInfo_nodeset,
       item.originInfo.dateOther,
       item.part.detail.number,
       item.note_nodeset].flatten.compact.map!(&:text).map!(&:strip).join(' ')
    end

    def related_item_label(item)
      if displayLabel(item)
        displayLabel(item)
      else
        case
        when item.location?
          return I18n.t('mods_display.location')
        when item.reference?
          return I18n.t('mods_display.referenced_by')
        end
        I18n.t('mods_display.related_item')
      end
    end
  end
end
