# frozen_string_literal: true

module ModsDisplay
  class RelatedItem < Field
    include ModsDisplay::RelatedItemConcerns

    def initialize(related_item_elements, value_renderer: ValueRenderer)
      super(related_item_elements)
      @value_renderer = value_renderer
    end

    def fields
      return_fields = RelatedItemValue.for_stanford_mods_elements(@stanford_mods_elements).map do |related_item_element|
        next if related_item_element.collection?
        next if render_nested_related_item?(related_item_element)

        text = @value_renderer.new(related_item_element).render
        next if text.nil? || text.empty?

        ModsDisplay::Values.new(
          label: related_item_label(related_item_element),
          values: [text]
        )
      end.compact
      collapse_fields(return_fields)
    end

    # this class provides html markup and is mimicking the same class
    #   in NestedRelatedItem (which is subclassed in purl application)
    class ValueRenderer
      def initialize(related_item_element)
        @related_item_element = related_item_element
      end

      def render
        if related_item_element.location?
          element_text(related_item_element.location_nodeset)
        elsif related_item_element.reference?
          reference_title(related_item_element)
        elsif related_item_element.titleInfo_nodeset.any?
          title = element_text(related_item_element.titleInfo_nodeset)
          location = nil
          location = element_text(related_item_element.location_url_nodeset) if related_item_element.location_url_nodeset.length.positive?

          return if title.empty?

          if location
            "<a href='#{location}'>#{title}</a>".html_safe
          else
            title
          end
        elsif related_item_element.note_nodeset.any?
          citation = related_item_element.note_nodeset.find { |note| note['type'] == 'preferred citation' }

          element_text(citation) if citation
        end
      end

      protected

      attr_reader :related_item_element

      def element_text(element)
        element.xpath('.//text()').to_html.strip
      end

      def reference_title(related_item_element)
        [related_item_element.titleInfo_nodeset,
         related_item_element.originInfo.dateOther,
         related_item_element.part.detail.number,
         related_item_element.note_nodeset].flatten.compact.map!(&:text).map!(&:strip).join(' ')
      end
    end

    private

    def related_item_label(related_item_element)
      if displayLabel(related_item_element)
        displayLabel(related_item_element)
      else
        case
        when related_item_element.location?
          return I18n.t('mods_display.location')
        when related_item_element.reference?
          return I18n.t('mods_display.referenced_by')
        end
        I18n.t('mods_display.related_item')
      end
    end
  end
end
