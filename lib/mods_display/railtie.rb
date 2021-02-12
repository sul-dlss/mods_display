# frozen_string_literal: true

module ModsDisplay
  class Railtie < ::Rails::Railtie
    ActiveSupport.on_load :action_view do
      require 'mods_display/helpers/record_helper'
      ::ActionView::Base.send :include, ModsDisplay::Helpers::RecordHelper
    end
  end
end
