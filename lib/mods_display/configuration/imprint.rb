class ModsDisplay::Configuration::Imprint < ModsDisplay::Configuration::Base
  def full_date_format full_date_format="%B %d, %Y"
    @full_date_format ||= full_date_format
  end
  def short_date_format short_date_format="%B %Y"
    @short_date_format ||= short_date_format
  end
end