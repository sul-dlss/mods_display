# frozen_string_literal: true

module ModsDisplay
  ##
  # This class will hopefully take over for related item support more broadly.
  # Currently there is behavior in RelatedItem and Collection that would need
  # to be accounted for when adding nested metadata support.
  class NestedRelatedItem < Field
    include ModsDisplay::RelatedItemConcerns

    def fields
      @fields ||= begin
        return_fields = RelatedItemValue.for_values(@values).map do |value|
          next if value.collection?
          next unless render_nested_related_item?(value)

          related_item_mods_object(value)
        end.compact
        collapse_fields(return_fields)
      end
    end

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

    private

    def related_item_mods_object(value)
      mods = ::Stanford::Mods::Record.new.tap do |r|
        # dup'ing the value adds the appropriate namespaces, but...
        munged_node = value.dup.tap do |x|
          # ... the mods gem also expects the root of the document to have the root tag <mods>
          x.name = 'mods'
        end

        r.from_nk_node(munged_node)
      end
      related_item = ModsDisplay::HTML.new(mods)

      ModsDisplay::Values.new(
        label: related_item_label(value),
        values: [[Array.wrap(related_item.title).first, related_item_body(related_item)].compact.join]
      )
    end

    def related_item_body(related_item)
      body = related_item.body

      return if body == '<dl></dl>'

      body
    end

    def related_item_label(item)
      return displayLabel(item) if displayLabel(item)
      return I18n.t('mods_display.constituent') if item.constituent?

      I18n.t('mods_display.host')
    end
  end
end
