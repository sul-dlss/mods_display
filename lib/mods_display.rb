require 'mods_display/version'
require 'mods_display/controller_extension'
require 'mods_display/html'
require 'mods_display/model_extension'
require 'mods_display/country_codes'
require 'mods_display/relator_codes'
require 'mods_display/related_item_concerns'
require 'mods_display/configuration'
require 'mods_display/configuration/base'
require 'mods_display/configuration/access_condition'
require 'mods_display/configuration/imprint'
require 'mods_display/configuration/genre'
require 'mods_display/configuration/name'
require 'mods_display/configuration/note'
require 'mods_display/configuration/related_item'
require 'mods_display/configuration/subject'
require 'mods_display/configuration/title'
require 'mods_display/fields/field'
require 'mods_display/fields/abstract'
require 'mods_display/fields/access_condition'
require 'mods_display/fields/audience'
require 'mods_display/fields/collection'
require 'mods_display/fields/contact'
require 'mods_display/fields/contents'
require 'mods_display/fields/cartographics'
require 'mods_display/fields/description'
require 'mods_display/fields/extent'
require 'mods_display/fields/form'
require 'mods_display/fields/genre'
require 'mods_display/fields/geo'
require 'mods_display/fields/identifier'
require 'mods_display/fields/imprint'
require 'mods_display/fields/language'
require 'mods_display/fields/location'
require 'mods_display/fields/name'
require 'mods_display/fields/nested_related_item'
require 'mods_display/fields/note'
require 'mods_display/fields/related_item'
require 'mods_display/fields/resource_type'
require 'mods_display/fields/subject'
require 'mods_display/fields/sub_title'
require 'mods_display/fields/title'
require 'mods_display/fields/values'

require 'stanford-mods'

require 'i18n'
require 'i18n/backend/fallbacks'
I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
I18n.load_path += Dir["#{File.expand_path('../..', __FILE__)}/config/locales/*.yml"]
I18n.backend.load_translations

# load Rails/Railtie
begin
  require 'rails'
rescue LoadError
  #do nothing
end

if defined? ::Rails::Railtie
  require 'mods_display/railtie'
end
