# frozen_string_literal: true

module ModsDisplay
  class RelatedItem < Field
    include ModsDisplay::RelatedItemConcerns

    def initialize(values, value_renderer: ValueRenderer)
      super(values)
      @value_renderer = value_renderer
    end

    def fields
      return_fields = RelatedItemValue.for_values(@values).map do |value|
        next if value.collection?
        next if render_nested_related_item?(value)

        text = @value_renderer.new(value).render

        next if text.nil? || text.empty?

        ModsDisplay::Values.new(label: related_item_label(value), values: [text])
      end.compact
      collapse_fields(return_fields)
    end

    class ValueRenderer
      def initialize(value)
        @value = value
      end

      def render
        if value.location?
          element_text(value.location_nodeset)
        elsif value.reference?
          reference_title(value)
        elsif value.titleInfo_nodeset.any?
          title = element_text(value.titleInfo_nodeset)
          location = nil
          location = element_text(value.location_url_nodeset) if value.location_url_nodeset.length.positive?

          return if title.empty?

          if location
            "<a href='#{location}'>#{title}</a>".html_safe
          else
            title
          end
        elsif value.note_nodeset.any?
          citation = value.note_nodeset.find { |note| note['type'] == 'preferred citation' }

          element_text(citation) if citation
        end
      end

      protected

      attr_reader :value

      def element_text(element)
        element.xpath('.//text()').to_html.strip
      end

      def reference_title(item)
        [item.titleInfo_nodeset,
         item.originInfo.dateOther,
         item.part.detail.number,
         item.note_nodeset].flatten.compact.map!(&:text).map!(&:strip).join(' ')
      end
    end

    private

    attr_reader :value_renderer

    def delimiter
      '<br />'.html_safe
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
