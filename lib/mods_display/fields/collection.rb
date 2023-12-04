# frozen_string_literal: true

module ModsDisplay
  ###
  #  Collection class to parse collection data out of Mods relatedItem fields
  ###
  class Collection < Field
    def collection_label(related_item_element)
      displayLabel(related_item_element) || I18n.t('mods_display.collection')
    end

    def fields
      return_fields = []
      @stanford_mods_elements.each do |related_item_element|
        next unless related_item_is_a_collection?(related_item_element)

        return_fields << ModsDisplay::Values.new(
          label: collection_label(related_item_element),
          values: [element_text(related_item_element.titleInfo)]
        )
      end
      collapse_fields(return_fields)
    end

    private

    def related_item_is_a_collection?(related_item_element)
      related_item_element.respond_to?(:titleInfo) && resource_type_is_collection?(related_item_element)
    end

    def resource_type_is_collection?(related_item_element)
      return false unless related_item_element.respond_to?(:typeOfResource)
      return false unless related_item_element.typeOfResource.attributes.length.positive?

      related_item_element.typeOfResource.attributes.length.positive? &&
        related_item_element.typeOfResource.attributes.first.key?('collection') &&
        related_item_element.typeOfResource.attributes.first['collection'].value == 'yes'
    end
  end
end
