module ModsDisplay
  class Name < Field
    include ModsDisplay::RelatorCodes
    def fields
      return_fields = @values.map do |value|
        roles = process_role(value)
        person = nil
        if value.displayForm.length > 0
          person = ModsDisplay::Name::Person.new(name: value.displayForm.text, roles: roles)
        elsif !name_parts(value).empty?
          person = ModsDisplay::Name::Person.new(name: name_parts(value), roles: roles)
        end
        ModsDisplay::Values.new(label: displayLabel(value) || name_label(value), values: [person]) if person
      end.compact
      collapse_fields(return_fields)
    end

    def to_html
      return nil if fields.empty? || @config.ignore?
      output = ''
      fields.each do |field|
        output << "<dt#{label_class} #{sanitized_field_title(field.label)}>#{field.label}</dt>"
        output << "<dd#{value_class}>"
        output << field.values.map do |val|
          if @config.link
            txt = link_to_value(val.name)
            txt << " (#{val.roles.join(', ')})" if val.roles
            txt
          else
            val.to_s
          end
        end.join(@config.delimiter)
        output << '</dd>'
      end
      output
    end

    private

    def name_label(element)
      if !role?(element) || primary?(element) || author_or_creator_roles?(element)
        I18n.t('mods_display.author_creator')
      else
        I18n.t('mods_display.contributor')
      end
    end

    def role?(element)
      element.respond_to?(:role) && !element.role.empty?
    end

    def primary?(element)
      element.attributes['usage'].respond_to?(:value) &&
        element.attributes['usage'].value == 'primary'
    end

    def author_or_creator_roles?(element)
      ['author', 'aut', 'creator', 'cre', ''].include?(element.role.roleTerm.text.downcase)
    rescue
      false
    end

    def name_parts(element)
      output = ''
      output << [unqualified_name_parts(element),
                 qualified_name_parts(element, 'family'),
                 qualified_name_parts(element, 'given')].flatten.compact.join(', ')
      terms = qualified_name_parts(element, 'termsOfAddress')
      unless terms.empty?
        term_delimiter = ', '
        term_delimiter = ' ' if name_part_begins_with_roman_numeral?(terms.first)
        output = [output, terms.join(', ')].flatten.compact.join(term_delimiter)
      end
      dates = qualified_name_parts(element, 'date')
      unless dates.empty?
        output = [output, qualified_name_parts(element, 'date')].flatten.compact.join(', ')
      end
      output
    end

    def unqualified_name_parts(element)
      element.namePart.map do |part|
        part.text unless part.attributes['type']
      end.compact
    end

    def qualified_name_parts(element, type)
      element.namePart.map do |part|
        if part.attributes['type'].respond_to?(:value) &&
           part.attributes['type'].value == type
          part.text
        end
      end.compact
    end

    def name_part_begins_with_roman_numeral?(part)
      first_part = part.split(/\s|,/).first.strip
      first_part.chars.all? do |char|
        %w(I X C L V).include? char
      end
    end

    def process_role(element)
      return unless element.role.length > 0 && element.role.roleTerm.length > 0
      if unencoded_role_term?(element)
        unencoded_role_term(element)
      else
        element.role.roleTerm.map do |term|
          next unless term.attributes['type'].respond_to?(:value) &&
                      term.attributes['type'].value == 'code' &&
                      term.attributes['authority'].respond_to?(:value) &&
                      term.attributes['authority'].value == 'marcrelator' &&
                      relator_codes.include?(term.text.strip)
          relator_codes[term.text.strip]
        end.compact
      end
    end

    def unencoded_role_term(element)
      roles = element.role.map do |role|
        role.roleTerm.find do |term|
          term.attributes['type'].respond_to?(:value) &&
          term.attributes['type'].value == 'text'
        end
      end.compact
      roles = element.role.map do |role|
        role.roleTerm.find do |term|
          !term.attributes['type'].respond_to?(:value)
        end
      end.compact if roles.empty?
      roles.map { |t| t.text.strip }
    end

    def unencoded_role_term?(element)
      element.role.roleTerm.any? do |term|
        !term.attributes['type'].respond_to?(:value) ||
          term.attributes['type'].value == 'text'
      end
    end

    class Person
      attr_accessor :name, :roles
      def initialize(data)
        @name =  data[:name]
        @roles = data[:roles] && !data[:roles].empty? ? data[:roles] : nil
      end

      def to_s
        text = @name.dup
        text << " (#{@roles.join(', ')})" if @roles
        text
      end
    end
  end
end
