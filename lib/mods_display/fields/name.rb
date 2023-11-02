# frozen_string_literal: true

module ModsDisplay
  class Name < Field
    include ModsDisplay::RelatorCodes

    # this returns a hash:
    #  { role1 label => [ ModsDisplay:Name:Person,  ModsDisplay:Name:Person, ...], role2 label => [ ModsDisplay:Name:Person,  ModsDisplay:Name:Person, ...] }
    def fields
      return_fields = NameValue.for_values(@values).map do |value|
        person = if value.displayForm_nodeset.length.positive?
                   ModsDisplay::Name::Person.new(name: element_text(value.displayForm_nodeset), name_identifiers: value.nameIdentifier_nodeset)
                 elsif !(name_parts = name_parts(value)).empty?
                   ModsDisplay::Name::Person.new(name: name_parts, name_identifiers: value.nameIdentifier_nodeset)
                 end
        # The person may have multiple roles, so we have to divide them up into an array
        role_labels(value).collect do |role_label|
          ModsDisplay::Values.new(label: displayLabel(value) || role_label, values: [person]) if person
        end
      end.flatten.compact
      collapse_roles(collapse_fields(return_fields))
    end

    def to_html(view_context = ApplicationController.renderer)
      component = ModsDisplay::FieldComponent.with_collection(fields, value_transformer: ->(value) { value.to_s })

      view_context.render component, layout: false
    end

    private

    def delimiter
      '<br />'
    end

    # Override of Field#element_text to get text rather than HTML
    def element_text(element)
      element.text.strip
    end

    def collapse_roles(fields)
      return [] if fields.blank?

      label_order = fields.map(&:label)
      results = consolidate_under_labels(fields)
      label_keys = normalize_labels(label_order, results)
      rebuild_fields_with_new_labels(label_keys, results)
    end

    def role_labels(element)
      default_label = I18n.t('mods_display.associated_with')
      return [default_label] unless element.xpath('mods:role/mods:roleTerm', mods: MODS_NS).present?

      element.role_nodeset.collect do |role|
        codes, text = role.xpath('mods:roleTerm', mods: MODS_NS).partition { |term| term['type'] == 'code' }

        # prefer mappable role term codes
        label = codes.map { |term| relator_codes[term.text.downcase] }.first

        # but fall back to given text
        label ||= text.map { |term| format_role(term) }.first

        # or just the default
        label || default_label
      end.uniq
    end

    def format_role(element)
      element_text(element).capitalize.sub(/[.,:;]+$/, '')
    end

    def name_parts(element)
      output = [unqualified_name_parts(element),
                qualified_name_parts(element, 'family'),
                qualified_name_parts(element, 'given')].flatten.compact.join(', ')
      terms = qualified_name_parts(element, 'termsOfAddress')
      unless terms.empty?
        term_delimiter = ', '
        term_delimiter = ' ' if name_part_begins_with_roman_numeral?(terms.first)
        output = [output, terms.join(', ')].flatten.compact.join(term_delimiter)
      end
      dates = qualified_name_parts(element, 'date')
      output = [output, dates].flatten.compact.join(', ') unless dates.empty?
      output
    end

    def unqualified_name_parts(element)
      element.namePart_nodeset.map do |part|
        element_text(part) unless part.attributes['type']
      end.compact
    end

    def qualified_name_parts(element, type)
      element.namePart_nodeset.map do |part|
        element_text(part) if part.get_attribute('type') == type
      end.compact
    end

    def name_part_begins_with_roman_numeral?(part)
      first_part = part.split(/\s|,/).first.strip
      first_part.chars.all? do |char|
        %w[I X C L V].include? char
      end
    end

    # Consolidate all names under label headings
    def consolidate_under_labels(fields)
      results = {}
      fields.each do |mdv| # ModsDisplay::Values
        results[mdv.label] ||= []
        results[mdv.label] << mdv.values
        results[mdv.label].flatten!
      end
      results
    end

    # Normalize label headings by filtering out some punctuation and ending in :
    def normalize_labels(label_order, results)
      label_order.uniq.map do |k|
        label = "#{k.tr('.', '').tr(':', '').strip}:"
        if label != k
          results[label] = results[k]
          results.delete(k)
        end
        label
      end
    end

    def rebuild_fields_with_new_labels(label_keys, results)
      # Build the new fields data, stripping out the roles within the Person classes
      label_keys.uniq.map do |k|
        values = results[k].map do |person|
          ModsDisplay::Name::Person.new(name: person.name, orcid: person.orcid)
        end

        ModsDisplay::Values.new(label: k, values: values)
      end
    end

    class Person
      attr_accessor :name, :orcid

      def initialize(data)
        @name = data[:name]
        @orcid = if data[:orcid].present?
                   data[:orcid]
                 elsif data[:name_identifiers].present?
                   orcid_identifier(data[:name_identifiers])
                 end
      end

      def to_s
        @name
      end

      private

      def orcid_identifier(name_identifiers)
        orcid = name_identifiers.select do |name_identifier|
          name_identifier.get_attribute('type') == 'orcid'
        end
        orcid.first&.text
      end
    end

    class NameValue < SimpleDelegator
      def self.for_values(values)
        values.map { |value| new(value) }
      end

      def nameIdentifier_nodeset
        @nameIdentifier_nodeset ||= xpath('mods:nameIdentifier', mods: MODS_NS)
      end

      def displayForm_nodeset
        @displayForm_nodeset ||= xpath('mods:displayForm', mods: MODS_NS)
      end

      def namePart_nodeset
        @namePart_nodeset ||= xpath('mods:namePart', mods: MODS_NS)
      end

      def role_nodeset
        @role_nodeset ||= xpath('mods:role', mods: MODS_NS)
      end
    end
  end
end
