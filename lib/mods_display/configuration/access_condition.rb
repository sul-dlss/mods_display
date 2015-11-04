class ModsDisplay::Configuration::AccessCondition < ModsDisplay::Configuration::Base
  def delimiter(delimiter = '<br/>')
    @delimiter ||= delimiter
  end

  def ignore?
    @ignore.nil? ? true : @ignore
  end

  def display!
    @ignore = false
  end

  def cc_license_version(cc_license_version = '3.0')
    @cc_license_version ||= cc_license_version
  end
end
