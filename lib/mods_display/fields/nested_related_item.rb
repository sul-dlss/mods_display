# frozen_string_literal: true

module ModsDisplay
  ##
  # This class will hopefully take over for related item support more broadly.
  # Currently there is behavior in RelatedItem and Collection that would need
  # to be accounted for when adding nested metadata support.
  class NestedRelatedItem < Field
    include ModsDisplay::RelatedItemConcerns

    def initialize(values, value_renderer: ValueRenderer)
      super(values)
      @value_renderer = value_renderer
    end

    def fields
      @fields ||= begin
        return_fields = RelatedItemValue.for_values(@values).map do |value|
          next if value.collection?
          next unless render_nested_related_item?(value)

          related_item_text = @value_renderer.new(value).render

          ModsDisplay::Values.new(
            label: related_item_label(value),
            values: [related_item_text]
          )
        end.compact
        collapse_fields(return_fields)
      end
    end

    class ValueRenderer
      def initialize(value)
        @value = value
      end

      def render
        [Array.wrap(mods_display_html.title).first, body_presence(mods_display_html.body)].compact.join
      end

      protected

      attr_reader :value

      def mods_display_html
        @mods_display_html ||= ModsDisplay::HTML.new(mods)
      end

      def mods
        @mods ||= ::Stanford::Mods::Record.new.tap do |r|
          # dup'ing the value adds the appropriate namespaces, but...
          munged_node = value.dup.tap do |x|
            # ... the mods gem also expects the root of the document to have the root tag <mods>
            x.name = 'mods'
          end

          r.from_nk_node(munged_node)
        end
      end

      def body_presence(body)
        return if body == '<dl></dl>'

        body
      end
    end

    private

    def related_item_label(item)
      return displayLabel(item) if displayLabel(item)
      return I18n.t('mods_display.constituent') if item.constituent?

      I18n.t('mods_display.host')
    end
  end
end
