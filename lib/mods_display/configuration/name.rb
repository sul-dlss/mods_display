class ModsDisplay::Configuration::Name < ModsDisplay::Configuration::Base
  def delimiter(delimiter = '<br/>')
    @delimiter ||= delimiter
  end
end
