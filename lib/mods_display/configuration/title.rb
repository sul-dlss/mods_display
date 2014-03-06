class ModsDisplay::Configuration::Title < ModsDisplay::Configuration::Base
  def delimiter delimiter="<br/>"
    @delimiter ||= delimiter
  end
end