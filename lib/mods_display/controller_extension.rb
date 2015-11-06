module ModsDisplay
  module ControllerExtension
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        def mods_display_config
          @mods_display_config || self.class.mods_display_config
        end
        if base.respond_to?(:helper_method)
          helper_method :mods_display_config, :render_mods_display
        end
      end
    end

    def render_mods_display(model)
      return '' if model.mods_display_xml.nil?
      ModsDisplay::HTML.new(mods_display_config, model.mods_display_xml, self)
    end

    private

    module ClassMethods
      def configure_mods_display(&config)
        @mods_display_config = ModsDisplay::Configuration.new(&config)
      end

      def mods_display_config
        @mods_display_config || ModsDisplay::Configuration.new {}
      end
    end
  end
end
