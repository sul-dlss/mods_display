# frozen_string_literal: true

module ModsDisplay
  class Geo < Field
    def fields
      return [] unless geo_extensions.present?

      extensions = geo_extensions.map(&method(:process_geo_extension))
      [
        ModsDisplay::Values.new(
          label: I18n.t('mods_display.geo_extension'),
          values: extensions
        )
      ]
    end

    private

    def process_geo_extension(extension)
      rdf = Nokogiri::XML(extension.children.to_s)
      [
        rdf.xpath('//dc:format', dc: 'http://purl.org/dc/elements/1.1/').text[/format=(.*)$/, 1],
        rdf.xpath('//dc:type', dc: 'http://purl.org/dc/elements/1.1/').text[/#(.*)$/, 1]
      ].compact.join('; ')
    end

    def geo_extensions
      @geo_extensions ||= @stanford_mods_elements.select do |extension_element|
        displayLabel(extension_element) =~ /^geo:?$/
      end
    end
  end
end
