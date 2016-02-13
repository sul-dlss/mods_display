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
        rdf.xpath('//format').text[/format=(.*)$/, 1],
        rdf.xpath('//type').text[/#(.*)$/, 1]
      ].compact.join('; ')
    end

    def geo_extensions
      @geo_values ||= @values.select do |value|
        displayLabel(value) =~ /^geo:?$/
      end
    end
  end
end
