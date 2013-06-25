class ModsDisplay::ResourceType < ModsDisplay::Field

  private
  def displayLabel(element)
    super(element) || "Type of resource"
  end
end