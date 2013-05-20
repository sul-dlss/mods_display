class ModsDisplay::RelatedItem < ModsDisplay::Field

  def label
    super || "Related Item"
  end

  def fields
    return_values = []
    return return_values if (@value.typeOfResource.length > 0 and
                             @value.typeOfResource.attributes.length > 0 and
                             @value.typeOfResource.attributes.first.has_key?("collection") and
                             @value.typeOfResource.attributes.first["collection"].value == "yes")
    if @value.titleInfo.length > 0
      title = @value.titleInfo.text.strip
      return_text = title
      location = nil
      location = @value.location.url.text if (@value.location.length > 0 and
                                              @value.location.url.length > 0)
      return_text = "<a href='#{location}'>#{title}</a>" if location
      return_values << ModsDisplay::Values.new(:label => label, :values => [return_text])
    end
    return_values
  end

end