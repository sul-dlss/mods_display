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

    def date_values(element, date_field_keys: %i[dateCreated dateCaptured dateValid dateModified copyrightDate])
      imprint = Stanford::Mods::Imprint.new(element)

      date_field_keys.map do |date_field|
        date_values = imprint.dates([date_field])
        next if date_values.empty?

        ModsDisplay::Values.new(
          label: displayLabel(element) || pub_info_labels[date_field],
          values: select_best_date(date_values)
        )
      end.compact
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
        element.xpath('mods:place/mods:placeTerm', mods: MODS_NS).select do |term|
          !term.attributes['type'].respond_to?(:value) ||
            term.attributes['type'].value == 'text'
        end.compact
      else
        element.xpath('mods:place/mods:placeTerm', mods: MODS_NS).map do |term|
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
      element.xpath('mods:place/mods:placeTerm', mods: MODS_NS).any? do |term|
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

    # not an exact duplicate of the method in ModsDisplay::Place, particularly trailing punctuation code
    #  as ModsDisplay::Place is not intended to combine with publisher in an imprint string
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

    def parts_element(value, date_field_keys: %i[dateIssued dateOther])
      imprint = Stanford::Mods::Imprint.new(value)

      date_elements = date_field_keys.map do |date_field|
        date_values = imprint.dates([date_field])
        next if date_values.empty?

        select_best_date(date_values)
      end.flatten.compact.reject do |date|
        date.strip.empty?
      end.map(&:strip)
      compact_and_join_with_delimiter(date_elements, ', ')
    end

    def pub_info_parts
      %i[issuance frequency]
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
