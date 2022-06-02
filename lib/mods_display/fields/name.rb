# frozen_string_literal: true

module ModsDisplay
  class Name < Field
    include ModsDisplay::RelatorCodes
    def fields
      return_fields = @values.map do |value|
        person = if value.displayForm.length.positive?
                   ModsDisplay::Name::Person.new(name: element_text(value.displayForm))
                 elsif !name_parts(value).empty?
                   ModsDisplay::Name::Person.new(name: name_parts(value))
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

    def collapse_roles(fields)
      return [] if fields.blank?

      label_order = fields.map(&:label)
      results = consolidate_under_labels(fields)
      label_keys = normalize_labels(label_order, results)
      rebuild_fields_with_new_labels(label_keys, results)
    end

    def role_labels(element)
      default_label = I18n.t('mods_display.associated_with')
      return [default_label] unless element.role.present? && element.role.roleTerm.present?

      element.role.collect do |role|
        codes, text = role.roleTerm.partition { |term| term['type'] == 'code' }

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

    def role?(element)
      element.respond_to?(:role) && !element.role.empty?
    end

    def primary?(element)
      element.attributes['usage'].respond_to?(:value) &&
        element.attributes['usage'].value == 'primary'
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
      output = [output, qualified_name_parts(element, 'date')].flatten.compact.join(', ') unless dates.empty?
      output
    end

    def unqualified_name_parts(element)
      element.namePart.map do |part|
        element_text(part) unless part.attributes['type']
      end.compact
    end

    def qualified_name_parts(element, type)
      element.namePart.map do |part|
        if part.attributes['type'].respond_to?(:value) &&
           part.attributes['type'].value == type
          element_text(part)
        end
      end.compact
    end

    def name_part_begins_with_roman_numeral?(part)
      first_part = part.split(/\s|,/).first.strip
      first_part.chars.all? do |char|
        %w[I X C L V].include? char
      end
    end

    def unencoded_role_term(element)
      roles = element.role.map do |role|
        role.roleTerm.find do |term|
          term.attributes['type'].respond_to?(:value) &&
            term.attributes['type'].value == 'text'
        end
      end.compact
      if roles.empty?
        roles = element.role.map do |role|
          role.roleTerm.find do |term|
            !term.attributes['type'].respond_to?(:value)
          end
        end.compact
      end
      roles.map { |t| element_text(t) }
    end

    def unencoded_role_term?(element)
      element.role.roleTerm.any? do |term|
        !term.attributes['type'].respond_to?(:value) ||
          term.attributes['type'].value == 'text'
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
          ModsDisplay::Name::Person.new(name: person.name)
        end

        ModsDisplay::Values.new(label: k, values: values)
      end
    end

    class Person
      attr_accessor :name

      def initialize(data)
        @name = data[:name]
      end

      def to_s
        @name
      end
    end
  end
end
