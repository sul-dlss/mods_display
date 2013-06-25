class ModsDisplay::Genre < ModsDisplay::Field


  private
  
  def displayLabel(element)
    super(element) || "Genre"
  end
end