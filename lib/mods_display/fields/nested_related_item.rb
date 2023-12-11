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
        return_fields = RelatedItemValue.for_values(@stanford_mods_elements).map do |related_item_element|
          next if related_item_element.collection?
          next unless render_nested_related_item?(related_item_element)

          related_item_text = @value_renderer.new(related_item_element).render

          ModsDisplay::Values.new(
            label: related_item_label(related_item_element),
            values: [related_item_text]
          )
        end.compact
        collapse_fields(return_fields)
      end
    end

    # Used by exhibits
    def to_html(view_context = ApplicationController.renderer)
      helpers = view_context.respond_to?(:simple_format) ? view_context : ApplicationController.new.view_context

      component = ModsDisplay::ListFieldComponent.with_collection(
        fields,
        value_transformer: ->(value) { helpers.format_mods_html(value.to_s) },
        list_html_attributes: { class: 'mods_display_nested_related_items' },
        list_item_html_attributes: { class: 'mods_display_nested_related_item open' }
      )

      view_context.render component, layout: false
    end

    # this class provides html markup and is subclassed in purl application
    class ValueRenderer
      def initialize(related_item_element)
        @related_item_element = related_item_element
      end

      def render
        [Array.wrap(mods_display_html.title).first, body_presence(mods_display_html.body)].compact.join
      end

      protected

      attr_reader :related_item_element

      def mods_display_html
        @mods_display_html ||= ModsDisplay::HTML.new(mods)
      end

      def mods
        @mods ||= ::Stanford::Mods::Record.new.tap do |r|
          # dup'ing the value adds the appropriate namespaces, but...
          munged_node = related_item_element.dup.tap do |x|
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

    def related_item_label(related_item_element)
      return displayLabel(related_item_element) if displayLabel(related_item_element)
      return I18n.t('mods_display.constituent') if related_item_element.constituent?

      I18n.t('mods_display.host')
    end
  end
end
