# frozen_string_literal: true

module ModsDisplay
  class NameFormatter
    def self.format(element)
      new(element).format
    end

    def initialize(element)
      @element = element
    end

    def format
      return element_text(display_form_nodeset) if display_form_nodeset.present?
      return name_parts if name_parts.present?

      nil
    end

    private

    attr_reader :element

    def name_parts
      @name_parts ||= begin
        output = [unqualified_name_parts(name_part_nodeset),
                  qualified_name_parts(name_part_nodeset, 'family'),
                  qualified_name_parts(name_part_nodeset, 'given')].flatten.compact.join(', ')
        terms = qualified_name_parts(name_part_nodeset, 'termsOfAddress')
        unless terms.empty?
          term_delimiter = ', '
          term_delimiter = ' ' if name_part_begins_with_roman_numeral?(terms.first)
          output = [output, terms.join(', ')].flatten.compact.join(term_delimiter)
        end
        dates = qualified_name_parts(name_part_nodeset, 'date')
        output = [output, dates].flatten.compact.join(', ') unless dates.empty?
        output
      end
    end

    def unqualified_name_parts(name_part_nodeset)
      name_part_nodeset.map do |part|
        element_text(part) unless part.attributes['type']
      end.compact
    end

    def qualified_name_parts(name_part_nodeset, type)
      name_part_nodeset.map do |part|
        element_text(part) if part.get_attribute('type') == type
      end.compact
    end

    def name_part_begins_with_roman_numeral?(part)
      first_part = part.split(/\s|,/).first.strip
      first_part.chars.all? do |char|
        %w[I X C L V].include? char
      end
    end

    def element_text(element)
      element.text.strip
    end

    def name_part_nodeset
      @name_part_nodeset ||= element.xpath('mods:namePart', mods: MODS_NS)
    end

    def display_form_nodeset
      @display_form_nodeset ||= element.xpath('mods:displayForm', mods: MODS_NS)
    end
  end
end
