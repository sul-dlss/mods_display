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

  def identifier &identifier
    @identifier ||=  ModsDisplay::Configuration::Base.new(&identifier || Proc.new{})
  end

  def extent &extent
    @extent ||= ModsDisplay::Configuration::Base.new(&extent || Proc.new{})
  end

  def self.field_mapping
    {:title => [:title_info, :title],
     :identifier => [:identifier],
     :extent => [:physical_description, :extent]
    }
  end

  def self.label_mapping
    {:title => "Title",
     :identifier => "Identifier",
     :extent => "Extent"
    }
  end
end