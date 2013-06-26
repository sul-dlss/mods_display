class ModsDisplay::Abstract < ModsDisplay::Field

  private
  def displayLabel(element)
    super(element) || "Abstract"
  end

end