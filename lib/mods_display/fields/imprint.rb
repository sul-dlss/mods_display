module ModsDisplay
  class Imprint < Field
    include ModsDisplay::CountryCodes
    def fields
      return_fields = []
      @values.each do |value|
        if imprint_display_form(value)
          return_fields << imprint_display_form(value)
        else
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
          return_fields.concat(dates(value)) if dates(value).length > 0
          if other_pub_info(value).length > 0
            other_pub_info(value).each do |pub_info|
              return_fields << ModsDisplay::Values.new(
                label: displayLabel(value) || pub_info_labels[pub_info.name.to_sym],
                values: [pub_info.text.strip]
              )
            end
          end
        end
      end
      collapse_fields(return_fields)
    end

    def dates(element)
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

    def parse_dates(date_field)
      apply_date_qualifier_decoration dedup_dates join_date_ranges process_encoded_dates ignore_bad_dates date_field
    end

    def ignore_bad_dates(date_fields)
      date_fields.select do |date_field|
        date_field.text.strip != '9999'
      end
    end

    def process_encoded_dates(date_fields)
      date_fields.map do |date_field|
        if date_is_w3cdtf?(date_field)
          process_w3cdtf_date(date_field)
        else
          date_field
        end
      end
    end

    def join_date_ranges(date_fields)
      if dates_are_range?(date_fields)
        start_date = date_fields.find { |d| d.attributes['point'] && d.attributes['point'].value == 'start' }
        end_date = date_fields.find { |d| d.attributes['point'] && d.attributes['point'].value == 'end' }
        date_fields.map do |date|
          date = date.clone # clone the date object so we don't append the same one
          if normalize_date(date.text) == normalize_date(start_date.text)
            date.content = [start_date.text, end_date.text].join('-')
            date
          elsif normalize_date(date.text) != normalize_date(end_date.text)
            date
          end
        end.compact
      elsif dates_are_open_range?(date_fields)
        start_date = date_fields.find { |d| d.attributes['point'] && d.attributes['point'].value == 'start' }
        date_fields.map do |date|
          date = date.clone # clone the date object so we don't append the same one
          date.content = "#{start_date.text}-" if date.text == start_date.text
          date
        end
      else
        date_fields
      end
    end

    def apply_date_qualifier_decoration(date_fields)
      return_fields = date_fields.map do |date|
        date = date.clone
        if date_is_approximate?(date)
          date.content = "[ca. #{date.text}]"
        elsif date_is_questionable?(date)
          date.content = "[#{date.text}?]"
        elsif date_is_inferred?(date)
          date.content = "[#{date.text}]"
        end
        date
      end
      return_fields.map(&:text)
    end

    def date_is_approximate?(date_field)
      date_field.attributes['qualifier'] &&
        date_field.attributes['qualifier'].respond_to?(:value) &&
        date_field.attributes['qualifier'].value == 'approximate'
    end

    def date_is_questionable?(date_field)
      date_field.attributes['qualifier'] &&
        date_field.attributes['qualifier'].respond_to?(:value) &&
        date_field.attributes['qualifier'].value == 'questionable'
    end

    def date_is_inferred?(date_field)
      date_field.attributes['qualifier'] &&
        date_field.attributes['qualifier'].respond_to?(:value) &&
        date_field.attributes['qualifier'].value == 'inferred'
    end

    def dates_are_open_range?(date_fields)
      date_fields.any? do |field|
        field.attributes['point'] &&
          field.attributes['point'].respond_to?(:value) &&
          field.attributes['point'].value == 'start'
      end && !date_fields.any? do |field|
        field.attributes['point'] &&
          field.attributes['point'].respond_to?(:value) &&
          field.attributes['point'].value == 'end'
      end
    end

    def dates_are_range?(date_fields)
      attributes = date_fields.map do |date|
        if date.attributes['point'].respond_to?(:value)
          date.attributes['point'].value
        end
      end
      attributes.include?('start') &&
        attributes.include?('end')
    end

    def date_is_w3cdtf?(date_field)
      date_field.attributes['encoding'] &&
        date_field.attributes['encoding'].respond_to?(:value) &&
        date_field.attributes['encoding'].value.downcase == 'w3cdtf'
    end

    def process_w3cdtf_date(date_field)
      date_field = date_field.clone
      date_field.content = begin
        if date_field.text.strip =~ /^\d{4}-\d{2}-\d{2}$/
          Date.parse(date_field.text).strftime(@config.full_date_format)
        elsif date_field.text.strip =~ /^\d{4}-\d{2}$/
          Date.parse("#{date_field.text}-01").strftime(@config.short_date_format)
        else
          date_field.content
        end
      rescue
        date_field.content
      end
      date_field
    end

    def dedup_dates(date_fields)
      date_text = date_fields.map { |d| normalize_date(d.text) }
      if date_text != date_text.uniq
        if date_fields.find { |d| d.attributes['qualifier'].respond_to?(:value) }
          [date_fields.find { |d| d.attributes['qualifier'].respond_to?(:value) }]
        elsif date_fields.find { |d| !d.attributes['encoding'] }
          [date_fields.find { |d| !d.attributes['encoding'] }]
        else
          [date_fields.first]
        end
      else
        date_fields
      end
    end

    def normalize_date(date)
      date.strip.gsub(/^\[*ca\.\s*|c|\[|\]|\?/, '')
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

    def imprint_display_form(element)
      display_form = element.children.find do |child|
        child.name == 'displayForm'
      end
      ModsDisplay::Values.new(
        label: displayLabel(element) || I18n.t('mods_display.imprint'),
        values: [display_form.text]
      ) if display_form
    end

    private

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
