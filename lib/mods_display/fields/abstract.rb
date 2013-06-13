class ModsDisplay::Abstract < ModsDisplay::Field

  def label
    super || "Abstract"
  end

end