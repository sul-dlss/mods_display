# frozen_string_literal: true

module ModsDisplay
  class Imprint < Field
    include ModsDisplay::CountryCodes

    def fields
      collapse_fields(origin_info_data.flatten)
    end

    def origin_info_data
      @values.map do |value|
        return_fields = []

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
        return_fields.concat(date_values(value))

        other_pub_info(value).each do |pub_info|
          return_fields << ModsDisplay::Values.new(
            label: displayLabel(value) || pub_info_labels[pub_info.name.to_sym],
            values: [element_text(pub_info)]
          )
        end

        return_fields.compact
      end
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
        attr_reader :value
        delegate :text, :date, :point, :qualifier, :encoding, to: :value

        def initialize(value)
          @value = value
        end

        # True if the element text isn't blank or the placeholder "9999".
        def valid?
          text.present? && !['9999', '0000-00-00', 'uuuu'].include?(text.strip)
        end

        # Element text reduced to digits and hyphen. Captures date ranges and
        # negative (BCE) dates. Used for comparison/deduping.
        def base_value
          if text =~ /^\[?1\d{3}-\d{2}\??\]?$/
            return text.sub(/(\d{2})(\d{2})-(\d{2})/, '\1\2-\1\3')
          end

          text.gsub(/(?<![\d])(\d{1,3})([xu-]{1,3})/i) { "#{$1}#{'0' * $2.length}"}.scan(/[\d-]/).join
        end

        # Decoded version of the date, if it was encoded. Strips leading zeroes.
        def decoded_value
          return text.strip unless date

          unless encoding.present?
            return text.strip unless text =~ /^-?\d+$/ || text =~ /^[\dXxu?-]{4}$/
          end

          # Delegate to the appropriate decoding method, if any
          case value.precision
          when :day
            date.strftime('%B %e, %Y')
          when :month
            date.strftime('%B %Y')
          when :year
            year = date.year
            if year < 1
              "#{year.abs + 1} BCE"
            # Any dates before the year 1000 are explicitly marked CE
            elsif year > 1 && year < 1000
              "#{year} CE"
            else
              year.to_s
            end
          when :century
            return "#{(date.to_s[0..1].to_i + 1).ordinalize} century"
          when :decade
            return "#{date.year}s"
          else
            text.strip
          end
        end

        # Decoded date with "BCE" or "CE" and qualifier markers. See (outdated):
        # https://consul.stanford.edu/display/chimera/MODS+display+rules#MODSdisplayrules-3b.%3CoriginInfo%3E
        def qualified_value
          date = decoded_value

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

        # Base value as hyphen-joined string. Used for comparison/deduping.
        def base_value
          "#{@start&.base_value}-#{@stop&.base_value}"
        end

        # Base values as array. Used for comparison/deduping of individual dates.
        def base_values
          [@start&.base_value, @stop&.base_value].compact
        end

        # The encoding value for the start of the range, or stop if not present.
        def encoding
          @start&.encoding || @stop&.encoding
        end

        # Decoded dates with "BCE" or "CE" and qualifier markers applied to
        # the entire range, or individually if dates differ.
        def qualified_value
          if @start&.qualifier == @stop&.qualifier
            qualifier = @start&.qualifier || @stop&.qualifier
            date = "#{@start&.decoded_value}-#{@stop&.decoded_value}"
            return "[ca. #{date}]" if qualifier == 'approximate'
            return "[#{date}?]" if qualifier == 'questionable'
            return "[#{date}]" if qualifier == 'inferred'

            date
          else
            "#{@start&.qualified_value}-#{@stop&.qualified_value}"
          end
        end
      end
    def parse_dates(elements)
      # convert to DateValue objects and keep only valid ones
      dates = elements.map(&:as_object).flatten.map { |element| DateValue.new(element) }.select(&:valid?)

      # join any date ranges into DateRange objects
      point, nonpoint = dates.partition(&:point)
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

        # otherwise just randomly pick the last in the group
        else
          group.last
        end
      end

      # if any single dates are already part of a range, discard them
      range_base_values = dates.select { |date| date.is_a?(DateRange) }
                               .map(&:base_values).flatten
      dates = dates.reject { |date| range_base_values.include?(date.base_value) }

      # output formatted dates with qualifiers, CE/BCE, etc.
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
        value << if (compact_values.length - 1) == i || # last item?
                    ends_in_terminating_punctuation?(value)
                   ' '
                 else
                   delimiter
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
      date_elements = %w[dateIssued dateOther].map do |date_field_name|
        next unless value.respond_to?(date_field_name.to_sym)

        parse_dates(value.send(date_field_name.to_sym))
      end.flatten.compact.reject do |date|
        date.strip.empty?
      end.map(&:strip)
      compact_and_join_with_delimiter(date_elements, ', ')
    end

    def pub_info_parts
      %i[issuance frequency]
    end

    def date_field_keys
      %i[dateCreated dateCaptured dateValid dateModified copyrightDate]
    end

    def pub_info_labels
      { dateCreated: I18n.t('mods_display.date_created'),
        dateCaptured: I18n.t('mods_display.date_captured'),
        dateValid: I18n.t('mods_display.date_valid'),
        dateModified: I18n.t('mods_display.date_modified'),
        copyrightDate: I18n.t('mods_display.copyright_date'),
        issuance: I18n.t('mods_display.issuance'),
        frequency: I18n.t('mods_display.frequency') }
    end
  end
end
