class ModsDisplay::Contents < ModsDisplay::Field

  private
  def displayLabel(element)
    super(element) || "Table of contents"
  end

end