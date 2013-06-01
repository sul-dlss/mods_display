class ModsDisplay::RelatedItem < ModsDisplay::Field

  def fields
    return_values = []
    current_label = nil
    prev_label = nil
    buffer = []
    @value.each_with_index do |val, index|
      current_label = (displayLabel(val) || "Related Item")
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
          return_text = "<a href='#{location}'>#{title}</a>" if location and !title.empty?
        end
        unless return_text.empty?
          if @value.length == 1
            return_values << ModsDisplay::Values.new(:label => current_label, :values => [return_text])
          elsif index == (@value.length-1)
            # need to deal w/ when we have a last element but we have separate labels in the buffer.
            if current_label != prev_label
              return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
              return_values << ModsDisplay::Values.new(:label => current_label, :values => [return_text])
            else
              buffer << return_text
              return_values << ModsDisplay::Values.new(:label => current_label, :values => buffer.flatten)
            end
          elsif prev_label and (current_label != prev_label)
            return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
            buffer = []
          end
          buffer << return_text
          prev_label = current_label
        end
      end
    end
    return_values
  end

end