class ModsDisplay::Configuration::RelatedItem < ModsDisplay::Configuration::Base
  def delimiter(delimiter = '<br/>')
    @delimiter ||= delimiter
  end
end
