class ModsDisplay::RelatedItem < ModsDisplay::Field

  def fields
    return_values = []
    @value.each do |val|
      unless (val.typeOfResource.length > 0 and
              val.typeOfResource.attributes.length > 0 and
              val.typeOfResource.attributes.first.has_key?("collection") and
              val.typeOfResource.attributes.first["collection"].value == "yes")              
        if val.titleInfo.length > 0
          title = val.titleInfo.text.strip
          return_text = title
          location = nil
          location = val.location.url.text if (val.location.length > 0 and
                                               val.location.url.length > 0)
          return_text = "<a href='#{location}'>#{title}</a>" if location
          return_values << ModsDisplay::Values.new(:label => displayLabel(val) || "Related Item", :values => [return_text])
        end
      end
    end
    return_values
  end

end