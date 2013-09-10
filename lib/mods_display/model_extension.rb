module ModsDisplay::ModelExtension

  def self.included(base)
    base.extend ClassMethods
    base.class_eval do
      def mods_display_xml
        xml = self.class.mods_xml_source.call(self)
        return if xml.nil?
        mods = Stanford::Mods::Record.new
        mods.from_str(xml, false)
        mods
      end
    end
  end

  module ClassMethods
    def mods_xml_source &xml
      @mods_xml_source ||= xml
    end
  end
end