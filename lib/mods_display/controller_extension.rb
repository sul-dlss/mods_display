module ModsDisplay
  module ControllerExtension
    def self.included(base)
      base.class_eval do
        if base.respond_to?(:helper_method)
          helper_method :render_mods_display
        end
      end
    end

    def render_mods_display(model)
      return '' if model.mods_display_xml.nil?
      ModsDisplay::HTML.new(model.mods_display_xml)
    end
  end
end
