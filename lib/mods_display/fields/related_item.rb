class ModsDisplay::RelatedItem < ModsDisplay::Field

  def fields
    return_fields = @values.map do |value|
      unless related_item_is_a_collection?(value)
        case
          when related_item_is_a_location?(value)
            process_location value
          when related_item_is_a_reference?(value)
            process_reference value
          else
            process_related_item(value)
        end
      end
    end.compact
    collapse_fields(return_fields)
  end

  private

  def process_location(item)
    ModsDisplay::Values.new(:label => related_item_label(item), :values => [item.location.text.strip])
  end

  def process_reference(item)
    ModsDisplay::Values.new(:label => related_item_label(item), :values => [reference_title(item)])
  end

  def process_related_item(item)
    if item.titleInfo.length > 0
      title = item.titleInfo.text.strip
      return_text = title
      location = nil
      location = item.location.url.text if (item.location.length > 0 and
                                            item.location.url.length > 0)
      return_text = "<a href='#{location}'>#{title}</a>" if location and !title.empty?
      unless return_text.empty?
        ModsDisplay::Values.new(:label => related_item_label(item), :values => [return_text])
      end
    end
  end

  def reference_title(item)
    [item.titleInfo,
     item.originInfo.dateOther,
     item.part.detail.number,
     item.note].flatten.compact.map!(&:text).map!(&:strip).join(" ")
  end

  def related_item_is_a_collection?(item)
    item.respond_to?(:titleInfo) and
    item.respond_to?(:typeOfResource) and
    item.typeOfResource.attributes.length > 0 and
    item.typeOfResource.attributes.first.has_key?("collection") and
    item.typeOfResource.attributes.first["collection"].value == "yes"
  end

  def related_item_is_a_location?(item)
    !related_item_is_a_collection?(item) and
    !related_item_is_a_reference?(item) and
     item.location.length > 0 and
     item.titleInfo.length < 1
  end

  def related_item_is_a_reference?(item)
    !related_item_is_a_collection?(item) and
     item.attributes["type"].respond_to?(:value) and
     item.attributes["type"].value == "isReferencedBy"
  end

  def related_item_label(item)
    if displayLabel(item)
      return displayLabel(item)
    else
      case
      when related_item_is_a_location?(item)
        return I18n.t('mods_display.location')
      when related_item_is_a_reference?(item)
        return I18n.t('mods_display.referenced_by')
      end
      I18n.t('mods_display.related_item')
    end
  end
end