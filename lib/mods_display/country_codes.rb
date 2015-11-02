# encoding: utf-8
module ModsDisplay::CountryCodes
  def country_codes
    @country_codes ||= begin
      countries = TZInfo::Country.all
      countries.map {|c| [c.code, c.name] }.to_h
    end
  end
end
