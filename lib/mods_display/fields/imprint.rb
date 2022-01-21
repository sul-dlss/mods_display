module ModsDisplay
  class Imprint < Field
    include ModsDisplay::CountryCodes
    def fields
      return_fields = []
      @values.each do |value|
        edition = edition_element(value)
        place = place_element(value)
        publisher = publisher_element(value)
        parts = parts_element(value)
        place_pub = compact_and_join_with_delimiter([place, publisher], ' : ')
        edition_place = compact_and_join_with_delimiter([edition, place_pub], ' - ')
        joined_place_parts = compact_and_join_with_delimiter([edition_place, parts], ', ')
        unless joined_place_parts.empty?
          return_fields << ModsDisplay::Values.new(
            label: displayLabel(value) || I18n.t('mods_display.imprint'),
            values: [joined_place_parts]
          )
        end
        return_fields.concat(date_values(value)) if date_values(value).length > 0
        if other_pub_info(value).length > 0
          other_pub_info(value).each do |pub_info|
            return_fields << ModsDisplay::Values.new(
              label: displayLabel(value) || pub_info_labels[pub_info.name.to_sym],
              values: [pub_info.text.strip]
            )
          end
        end
      end
      collapse_fields(return_fields)
    end

    def date_values(element)
      date_field_keys.map do |date_field|
        next unless element.respond_to?(date_field)
        elements = element.send(date_field)
        next if elements.empty?
        ModsDisplay::Values.new(
          label: displayLabel(element) || pub_info_labels[elements.first.name.to_sym],
          values: parse_dates(elements)
        )
      end.compact
    end

    class DateValue
      def initialize(element)
        @element = element
      end

      # True if the element text isn't blank or the placeholder "9999".
      def valid?
        @element.text.strip != '9999' && !@element.text.blank?
      end

      # Value of element's "point" attribute; nil if empty or not present.
      # Points are "start" or "end" (if part of a date range)
      def point
        @element.attributes['point']&.value.presence
      end

      # Value of element's "qualifier" attribute; nil if empty or not present.
      # Qualifiers are "approximate", "questionable", or "inferred"
      def qualifier
        @element.attributes['qualifier']&.value&.downcase.presence
      end

      # Value of element's "encoding" attribute; nil if empty or not present.
      # Encodings are "w3cdtf", "iso8601", or "edtf"
      def encoding
        @element.attributes['encoding']&.value&.downcase.presence
      end

      # Element text reduced to digits and hyphen. Captures date ranges and
      # negative (B.C.) dates. Used for comparison/deduping.
      def base_value
        @element.text.scan(/[\d-]/).join
      end

      # Human-formatted version of the date.
      def decoded_value
        date = @element.text.strip

        decoded_date = if encoding == 'w3cdtf'
          begin
            if date =~ /^\d{4}-\d{2}-\d{2}$/
              Date.parse(date).strftime('%B %e, %Y')
            elsif date =~ /^\d{4}-\d{2}$/
              Date.parse("#{date}-01").strftime('%B %Y')
            else
              date
            end
          rescue
            date
          end
            elsif encoding == 'iso8601'
              begin
                Date.iso8601(date).strftime('%B %e, %Y')
              rescue
                date
              end
            else
              date
          end

        # Year zero is a special case; preserve it as "0"
        return decoded_date if decoded_date == '0'

        # Any other leading zeroes should be stripped
        decoded_date.gsub(/^0*/, '')
      end

      # Decoded version of the date with "B.C." or "A.D." appended.
      def bc_ad_value
        date = decoded_value

        # Negative edtf dates are B.C. and may still have leading zeroes to remove
        if encoding == 'edtf' && date.to_i < 1
          year = date.gsub(/^-0*/, '').to_i + 1
          "#{year} B.C."

        # Any dates before the year 1000 are explicitly marked A.D.
        elsif date.match?(/^\d{1,3}$/)
          "#{date} A.D."

        # Leave the value alone otherwise; A.D. is implied
        else
          date
        end
      end

      # Decoded date with "B.C." or "A.D." and qualifier markers. See (outdated):
      # https://consul.stanford.edu/display/chimera/MODS+display+rules#MODSdisplayrules-3b.%3CoriginInfo%3E
      def qualified_value
        date = bc_ad_value
        return "[ca. #{date}]" if qualifier == 'approximate'
        return "[#{date}?]" if qualifier == 'questionable'
        return "[#{date}]" if qualifier == 'inferred'
        date
      end
    end

    class DateRange
      def initialize(start: nil, stop: nil)
        @start = start
        @stop = stop
      end

      def base_value
        "#{@start&.base_value}-#{@stop&.base_value}"
      end

      # The encoding value for the start date in the range.
      def encoding
        @start&.encoding || @stop&.encoding
      end

      def qualified_value
        if @start&.qualifier != @stop&.qualifier
          "#{@start&.qualified_value}-#{@stop&.qualified_value}"
        else
          qualifier = @start&.qualifier || @stop&.qualifier
          date = "#{@start&.bc_ad_value}-#{@stop&.bc_ad_value}"
          return "[ca. #{date}]" if qualifier == 'approximate'
          return "[#{date}?]" if qualifier == 'questionable'
          return "[#{date}]" if qualifier == 'inferred'
          date
        end
      end
    end

    def parse_dates(elements)
      # convert to DateValue objects and keep only valid ones
      dates = elements.map { |element| DateValue.new(element) }.select(&:valid?)

      # join any date ranges into DateRange objects
      point, nonpoint = dates.partition { |date| date.point }
      if point.any?
        range = DateRange.new(start: point.find { |date| date.point == 'start' },
                              stop: point.find { |date| date.point == 'end' })
        nonpoint.unshift(range)
      end
      dates = nonpoint

      # ensure dates are unique with respect to their base values
      dates = dates.group_by(&:base_value).map do |_value, group|
        group.first if group.one?

        # if one of the duplicates wasn't encoded, use that one. see:
        # https://consul.stanford.edu/display/chimera/MODS+display+rules#MODSdisplayrules-3b.%3CoriginInfo%3E
        if group.reject(&:encoding).any?
          group.reject(&:encoding).first

        # otherwise just randomly pick the first in the group
        else
          group.first
        end
      end

      # output formatted dates with qualifiers, A.D./B.C., etc.
      dates.map(&:qualified_value)
    end

    def other_pub_info(element)
      element.children.select do |child|
        pub_info_parts.include?(child.name.to_sym)
      end
    end

    def place_terms(element)
      return [] unless element.respond_to?(:place) &&
                       element.place.respond_to?(:placeTerm)
      if unencoded_place_terms?(element)
        element.place.placeTerm.select do |term|
          !term.attributes['type'].respond_to?(:value) ||
            term.attributes['type'].value == 'text'
        end.compact
      else
        element.place.placeTerm.map do |term|
          next unless term.attributes['type'].respond_to?(:value) &&
                      term.attributes['type'].value == 'code' &&
                      term.attributes['authority'].respond_to?(:value) &&
                      term.attributes['authority'].value == 'marccountry' &&
                      country_codes.include?(term.text.strip)
          term = term.clone
          term.content = country_codes[term.text.strip]
          term
        end.compact
      end
    end

    def unencoded_place_terms?(element)
      element.place.placeTerm.any? do |term|
        !term.attributes['type'].respond_to?(:value) ||
          term.attributes['type'].value == 'text'
      end
    end

    private

    def compact_and_join_with_delimiter(values, delimiter)
      compact_values = values.compact.reject { |v| v.strip.empty? }
      return compact_values.join(delimiter) if compact_values.length == 1 ||
                                               !ends_in_terminating_punctuation?(delimiter)
      compact_values.each_with_index.map do |value, i|
        if (compact_values.length - 1) == i || # last item?
           ends_in_terminating_punctuation?(value)
          value << ' '
        else
          value << delimiter
        end
      end.join.strip
    end

    def ends_in_terminating_punctuation?(value)
      value.strip.end_with?('.', ',', ':', ';')
    end

    def edition_element(value)
      value.edition.reject do |e|
        e.text.strip.empty?
      end.map(&:text).join(' ').strip
    end

    def place_element(value)
      return if value.place.text.strip.empty?
      places = place_terms(value).reject do |p|
        p.text.strip.empty?
      end.map(&:text)
      compact_and_join_with_delimiter(places, ' : ')
    end

    def publisher_element(value)
      return if value.publisher.text.strip.empty?
      publishers = value.publisher.reject do |p|
        p.text.strip.empty?
      end.map(&:text)
      compact_and_join_with_delimiter(publishers, ' : ')
    end

    def parts_element(value)
      date_elements = %w(dateIssued dateOther).map do |date_field_name|
        next unless value.respond_to?(date_field_name.to_sym)
        parse_dates(value.send(date_field_name.to_sym))
      end.flatten.compact.reject do |date|
        date.strip.empty?
      end.map(&:strip)
      compact_and_join_with_delimiter(date_elements, ', ')
    end

    def pub_info_parts
      [:issuance, :frequency]
    end

    def date_field_keys
      [:dateCreated, :dateCaptured, :dateValid, :dateModified, :copyrightDate]
    end

    def pub_info_labels
      { dateCreated: I18n.t('mods_display.date_created'),
        dateCaptured: I18n.t('mods_display.date_captured'),
        dateValid: I18n.t('mods_display.date_valid'),
        dateModified: I18n.t('mods_display.date_modified'),
        copyrightDate: I18n.t('mods_display.copyright_date'),
        issuance: I18n.t('mods_display.issuance'),
        frequency: I18n.t('mods_display.frequency')
      }
    end
  end
end
