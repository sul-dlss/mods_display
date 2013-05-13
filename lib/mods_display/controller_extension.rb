module ModsDisplay::ControllerExtension
  extend ActiveSupport::Concern
  
  included do
    helper_method :mods_display_config, :render_mods_display
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
        field_config = config.send(field_key)
        output << "<dt class='#{field_config.label_class}'>#{field.label}:</dt>"
        output << "<dd class='#{field_config.value_class}'>"
          if field_config.link
            if field.text.is_a?(Array)
              field.text.each do |text|
                output << "<a href='#{send(field_config.link[0], replace_tokens(field_config.link[1], text))}'>#{text}</a>"
              end
            else
              output << "<a href='#{send(field_config.link[0], replace_tokens(field_config.link[1], field.text))}'>#{field.text}</a>"
            end
          else
            output << field.text
          end
        output << "</dd>"
      end
    end
    output << "</dl>"
  end
  
  
  private
  
  def mods_display_fields
    [:title]
  end
  
  def mods_display_field_mapping
   {:title => :title_info}
  end
  
  def mods_label(xml, field)
    default_label = ModsDisplay::Configuration.label_mapping[field]
    fields = mods_field(xml, field)
    return default_label if fields.nil? or !fields.first.attributes["displayLabel"].respond_to?(:value)
    fields.first.attributes["displayLabel"].value
  end
  
  def mods_field(xml, field_key)
    if xml.respond_to?(mods_display_field_mapping[field_key])
      xml.send(mods_display_field_mapping[field_key]).map do |field|
        ModsDisplay.const_get(field_key.to_s.capitalize).new(field)
      end
    end
  end
  
  def replace_tokens(object, value)
    object = object.dup
    if object.is_a?(Hash)
      object.each do |k,v|
        object[k] = replace_token(v, value)
      end
    elsif object.is_a?(String)
      object = replace_token(object, value)
    end
    object
  end
  
  def replace_token(string, value)
    string = string.dup
    tokens.each do |token|
      string.gsub!(token, value)
    end
    string
  end
  
  def tokens
    ["%value%"]
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