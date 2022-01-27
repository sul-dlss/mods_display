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
        return_fields = @values.map do |value|
          next if related_item_is_a_collection?(value)
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
        value_transformer: ->(value) { helpers.link_urls_and_email(value.to_s) },
        list_html_attributes: { class: 'mods_display_nested_related_items' },
        list_item_html_attributes: { class: 'mods_display_nested_related_item open' }
      )

      view_context.render component, layout: false
    end

    private

    def related_item_mods_object(value)
      mods = ::Stanford::Mods::Record.new.tap do |r|
        r.from_str("<mods xmlns=\"http://www.loc.gov/mods/v3\">#{value.children.to_xml}</mods>")
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
      return I18n.t('mods_display.constituent') if related_item_is_a_constituent?(item)

      I18n.t('mods_display.host')
    end
  end
end
