module ModsDisplay
  ###
  #  Collection class to parse collection data out of Mods relatedItem fields
  ###
  class Collection < Field
    def label
      super || I18n.t('mods_display.collection')
    end

    def fields
      return_fields = []
      @values.each do |value|
        next unless related_item_is_a_collection?(value)
        return_fields << ModsDisplay::Values.new(
          label: label,
          values: [value.titleInfo.text.strip]
        )
      end
      collapse_fields(return_fields)
    end

    private

    def related_item_is_a_collection?(value)
      value.respond_to?(:titleInfo) && resource_type_is_collection?(value)
    end

    def resource_type_is_collection?(value)
      return unless value.respond_to?(:typeOfResource)
      return unless value.typeOfResource.attributes.length > 0
      value.typeOfResource.attributes.length > 0 &&
        value.typeOfResource.attributes.first.key?('collection') &&
        value.typeOfResource.attributes.first['collection'].value == 'yes'
    end
  end
end
