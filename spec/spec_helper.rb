ENV['RAILS_ENV'] ||= 'test'

require 'combustion'
Combustion.initialize! :action_controller, :action_view

require 'mods_display'
require 'stanford-mods'
require 'capybara'
require 'rspec/rails'

Dir["#{File.expand_path('..', __FILE__)}/fixtures/*.rb"].each { |file| require file }
# Load i18n test file.
# We don't have any reliable translations yet so this
# just make sure that we're handling i18n properly.
I18n.load_path += Dir["#{File.expand_path('../..', __FILE__)}/spec/test_fr.yml"]
I18n.backend.load_translations

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
  config.include Rails.application.routes.url_helpers
end
class TestModel
  attr_accessor :modsxml
  include ModsDisplay::ModelExtension
  mods_xml_source(&:modsxml)
end

class TestController
  include ModsDisplay::ControllerExtension

  def link_method(val)
    "http://library.stanford.edu?#{val}"
  end
end
