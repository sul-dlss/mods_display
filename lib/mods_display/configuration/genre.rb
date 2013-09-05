class ModsDisplay::Configuration::Genre < ModsDisplay::Configuration::Base
  def delimiter delimiter="<br/>"
    @delimiter ||= delimiter
  end
end