# frozen_string_literal: true

require 'mods/marc_country_codes'

module ModsDisplay
  module CountryCodes
    def country_codes
      @country_codes ||= MARC_COUNTRY.except('xx') # Removing per METADOR-32
    end
  end
end
