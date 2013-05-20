class ModsDisplay::Collection < ModsDisplay::Field

  def label
    super || "Collection"
  end

  def fields
    return_values = []
    if @value.respond_to?(:titleInfo) and
       @value.respond_to?(:typeOfResource) and
       @value.typeOfResource.attributes.length > 0 and
       @value.typeOfResource.attributes.first.has_key?("collection") and
       @value.typeOfResource.attributes.first["collection"].value == "yes"
      return_values << ModsDisplay::Values.new(:label => label, :values => [@value.titleInfo.text.strip])
    end
    return_values
  end

end