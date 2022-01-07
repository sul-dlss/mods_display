# frozen_string_literal: true

require 'view_component'

module ModsDisplay
  class Engine < ::Rails::Engine
    initializer 'mods_display.helpers' do
      config.after_initialize do
        ActionView::Base.include ModsDisplay::RecordHelper
      end
    end
  end
end
