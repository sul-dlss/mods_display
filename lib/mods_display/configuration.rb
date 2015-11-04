# We can probably do something smarter here using const_get to assign
# special coniguration classes then fall back on the base config class
class ModsDisplay::Configuration
  def initialize(&config)
    instance_eval &config
  end

  def title(&title)
    @title ||= ModsDisplay::Configuration::Title.new(&title || proc {})
  end

  def sub_title(&sub_title)
    @sub_title ||= ModsDisplay::Configuration::Title.new(&sub_title || proc {})
  end

  def name(&name)
    @name ||= ModsDisplay::Configuration::Name.new(&name || proc {})
  end

  def resource_type(&resource_type)
    @type_of_resource ||= ModsDisplay::Configuration::Base.new(&resource_type || proc {})
  end

  def genre(&genre)
    @genre ||= ModsDisplay::Configuration::Genre.new(&genre || proc {})
  end

  def format(&format)
    @format ||= ModsDisplay::Configuration::Format.new(&format || proc {})
  end

  def imprint(&imprint)
    @imprint ||= ModsDisplay::Configuration::Imprint.new(&imprint || proc {})
  end

  def language(&language)
    @language ||= ModsDisplay::Configuration::Base.new(&language || proc {})
  end

  def description(&description)
    @description ||= ModsDisplay::Configuration::Base.new(&description || proc {})
  end

  def cartographics(&cartographics)
    @cartographics ||= ModsDisplay::Configuration::Base.new(&cartographics || proc {})
  end

  def abstract(&abstract)
    @abstract ||= ModsDisplay::Configuration::Base.new(&abstract || proc {})
  end

  def contents(&contents)
    @contents ||= ModsDisplay::Configuration::Base.new(&contents || proc {})
  end

  def audience(&audience)
    @audience ||= ModsDisplay::Configuration::Base.new(&audience || proc {})
  end

  def note(&note)
    @note ||= ModsDisplay::Configuration::Note.new(&note || proc {})
  end

  def contact(&contact)
    @contact ||= ModsDisplay::Configuration::Base.new(&contact || proc {})
  end

  def collection(&collection)
    @collection ||= ModsDisplay::Configuration::Base.new(&collection || proc {})
  end

  def related_item(&related_item)
    @related_item ||= ModsDisplay::Configuration::RelatedItem.new(&related_item || proc {})
  end

  def subject(&subject)
    @subject ||= ModsDisplay::Configuration::Subject.new(&subject || proc {})
  end

  def identifier(&identifier)
    @identifier ||= ModsDisplay::Configuration::Base.new(&identifier || proc {})
  end

  def location(&location)
    @location ||= ModsDisplay::Configuration::Base.new(&location || proc {})
  end

  def access_condition(&access_condition)
    @access_condition ||= ModsDisplay::Configuration::AccessCondition.new(&access_condition || proc {})
  end
end
