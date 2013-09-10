class ModsDisplay::Configuration::Format < ModsDisplay::Configuration::Base
  def delimiter delimiter="<br/>"
    @delimiter ||= delimiter
  end
end