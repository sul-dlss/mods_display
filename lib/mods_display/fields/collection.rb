class ModsDisplay::Collection < ModsDisplay::Field

  def label
    super || "Collection"
  end

  def fields
    return_values = []
    @value.each do |val|
      if val.respond_to?(:titleInfo) and
         val.respond_to?(:typeOfResource) and
         val.typeOfResource.attributes.length > 0 and
         val.typeOfResource.attributes.first.has_key?("collection") and
         val.typeOfResource.attributes.first["collection"].value == "yes"
        return_values << ModsDisplay::Values.new(:label => label, :values => [val.titleInfo.text.strip])
      end
    end
    return_values
  end

end