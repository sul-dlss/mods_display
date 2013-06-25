class ModsDisplay::Abstract < ModsDisplay::Field

  private
  def dislayLabel(element)
    super(element) || "Abstract"
  end

end