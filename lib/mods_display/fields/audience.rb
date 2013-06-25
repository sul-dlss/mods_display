class ModsDisplay::Audience < ModsDisplay::Field

  private
  def displayLabel(element)
    super(element) || "Target audience"
  end

end