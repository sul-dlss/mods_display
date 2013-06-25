class ModsDisplay::ResourceType < ModsDisplay::Field
  def label
    super || "Type of resource"
  end
end