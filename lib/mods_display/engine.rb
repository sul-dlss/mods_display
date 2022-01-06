# frozen_string_literal: true

require 'view_component'

module ModsDisplay
  class Engine < ::Rails::Engine
    ActiveSupport.on_load :action_view do
      ::ActionView::Base.send :include, ModsDisplay::RecordHelper
    end
  end
end
