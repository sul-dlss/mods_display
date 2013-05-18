class ModsDisplay::Audience < ModsDisplay::Field

  def label
    super || "Target audience"
  end

end