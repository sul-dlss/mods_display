module ModsDisplay::ControllerExtension
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:helper_method)
      helper_method :mods_display_config, :render_mods_display
    end
  end

  def mods_display_config
    @mods_display_config || self.class.mods_display_config
  end

  def render_mods_display model
    return "" if model.mods_display_xml.nil?
    config = mods_display_config
    xml = model.mods_display_xml
    output = "<dl>"
    mods_display_fields.each do |field_key|
      fields = mods_field(xml, field_key)
      fields.each do |field|
        output << field.to_html unless field.to_html.nil?
      end
    end
    output << "</dl>"
  end

  private

  def mods_display_fields
    [:title, :imprint, :language]
  end

  def mods_display_field_mapping
   {:title => :title_info,
    :imprint => :origin_info,
    :language => :language}
  end

  def field_config(field_key)
    begin
      mods_display_config.send(field_key)
    rescue
      ModsDisplay::Configuration::Base.new
    end
  end

  def mods_field(xml, field_key)
    if xml.respond_to?(mods_display_field_mapping[field_key])
      xml.send(mods_display_field_mapping[field_key]).map do |field|
        ModsDisplay.const_get(field_key.to_s.capitalize).new(field, field_config(field_key), self)
      end
    end
  end

  module ClassMethods
    def configure_mods_display &config
      @mods_display_config = ModsDisplay::Configuration.new &config
    end

    def mods_display_config
      @mods_display_config 
    end
  end

end