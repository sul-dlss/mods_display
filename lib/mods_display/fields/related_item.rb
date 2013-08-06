class ModsDisplay::RelatedItem < ModsDisplay::Field

  def fields
    return_fields = @values.map do |value|
      unless (value.typeOfResource.length > 0 and
              value.typeOfResource.attributes.length > 0 and
              value.typeOfResource.attributes.first.has_key?("collection") and
              value.typeOfResource.attributes.first["collection"].value == "yes")
        if value.titleInfo.length > 0
          title = value.titleInfo.text.strip
          return_text = title
          location = nil
          location = value.location.url.text if (value.location.length > 0 and
                                                 value.location.url.length > 0)
          return_text = "<a href='#{location}'>#{title}</a>" if location and !title.empty?
          unless return_text.empty?
            ModsDisplay::Values.new(:label => displayLabel(value) || "Related item", :values => [return_text])
          end
        end
      end
    end.compact
    collapse_fields(return_fields)
  end

end