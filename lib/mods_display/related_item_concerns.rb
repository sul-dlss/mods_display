module ModsDisplay
  module RelatedItemConcerns
    private

    def render_nested_related_item?(item)
      related_item_is_a_constituent?(item) || related_item_is_host?(item)
    end

    def related_item_is_a_collection?(item)
      item.respond_to?(:titleInfo) &&
        item.respond_to?(:typeOfResource) &&
        !item.typeOfResource.attributes.empty? &&
        item.typeOfResource.attributes.first.key?('collection') &&
        item.typeOfResource.attributes.first['collection'].value == 'yes'
    end

    def related_item_is_a_constituent?(item)
      item.attributes['type'].respond_to?(:value) &&
      item.attributes['type'].value == 'constituent'
    end

    def related_item_is_host?(item)
      item.attributes['type'].respond_to?(:value) &&
      item.attributes['type'].value == 'host'
    end
  end
end
