module ModsDisplay::ModelExtension
  extend ActiveSupport::Concern
  
  included do
    after_initialize do 
      mods_display_xml
    end
  end
    
  def mods_display_xml
    xml = self.class.mods_xml_source.call(self)
    return if xml.nil?
    mods = Stanford::Mods::Record.new
    mods.from_str(xml, false)
  end
  
  module ClassMethods
    def mods_xml_source &xml
      @mods_xml_source ||= xml
    end
  end
end