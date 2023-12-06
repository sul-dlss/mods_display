# frozen_string_literal: true

module ModsDisplay
  module RelatedItemConcerns
    private

    def render_nested_related_item?(item)
      item.constituent? || item.host?
    end

    class RelatedItemValue < SimpleDelegator
      def collection?
        @collection ||= typeOfResource_nodeset.first&.get_attribute('collection') == 'yes'
      end

      def constituent?
        @constituent ||= type_attribute == 'constituent'
      end

      def host?
        @host ||= type_attribute == 'host'
      end

      def location?
        @location ||= !collection? &&
                      !reference? &&
                      location_nodeset.length.positive? &&
                      titleInfo_nodeset.empty?
      end

      def reference?
        @reference ||= !collection? && type_attribute == 'isReferencedBy'
      end

      def typeOfResource_nodeset
        @typeOfResource_nodeset ||= xpath('mods:typeOfResource', mods: MODS_NS)
      end

      def location_nodeset
        @location_nodeset ||= xpath('mods:location', mods: MODS_NS)
      end

      def location_url_nodeset
        @location_url_nodeset ||= xpath('mods:location/mods:url', mods: MODS_NS)
      end

      def titleInfo_nodeset
        @titleInfo_nodeset ||= xpath('mods:titleInfo', mods: MODS_NS)
      end

      def note_nodeset
        @note_nodeset ||= xpath('mods:note', mods: MODS_NS)
      end

      def type_attribute
        @type_attribute ||= get_attribute('type')
      end

      def self.for_stanford_mods_elements(stanford_mods_elements)
        stanford_mods_elements.map { |element| new(element) }
      end
    end
  end
end
