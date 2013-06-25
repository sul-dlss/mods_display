class ModsDisplay::Contents < ModsDisplay::Field

  def label
    super || "Table of contents"
  end

end