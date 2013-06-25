class ModsDisplay::Configuration::Note < ModsDisplay::Configuration::Base
  def delimiter delimiter="<br/>"
    @delimiter ||= delimiter
  end
end