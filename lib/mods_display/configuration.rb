class ModsDisplay::Configuration
  def initialize &config
    instance_eval &config
  end

  def title &title
    @title ||= ModsDisplay::Configuration::Base.new(&title || Proc.new{})
  end

  def imprint &imprint
    @imprint ||= ModsDisplay::Configuration::Base.new(&imprint || Proc.new{})
  end

  def language &language
    @language ||= ModsDisplay::Configuration::Base.new(&language || Proc.new{})
  end

end