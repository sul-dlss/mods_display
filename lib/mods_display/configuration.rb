class ModsDisplay::Configuration
  def initialize &config
    instance_eval &config
  end

  def title &title
    @title ||= ModsDisplay::Configuration::Base.new(&title || Proc.new{})
  end

  def format &format
    @format ||= ModsDisplay::Configuration::Base.new(&format || Proc.new{})
  end

  def imprint &imprint
    @imprint ||= ModsDisplay::Configuration::Base.new(&imprint || Proc.new{})
  end

  def language &language
    @language ||= ModsDisplay::Configuration::Base.new(&language || Proc.new{})
  end

  def description &description
    @description ||= ModsDisplay::Configuration::Base.new(&description || Proc.new{})
  end

  def cartographics &cartographics
    @cartographics ||= ModsDisplay::Configuration::Base.new(&cartographics || Proc.new{})
  end

  def abstract &abstract
    @abstract ||= ModsDisplay::Configuration::Base.new(&abstract || Proc.new{})
  end

  def contents &contents
    @contents ||= ModsDisplay::Configuration::Base.new(&contents || Proc.new{})
  end

end