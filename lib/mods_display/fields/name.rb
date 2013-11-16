class ModsDisplay::Name < ModsDisplay::Field
  include ModsDisplay::RelatorCodes
  def fields
    return_fields = @values.map do |value|
      roles = process_role(value)
      person = nil
      if value.displayForm.length > 0
        person = ModsDisplay::Name::Person.new(:name => value.displayForm.text, :roles => roles)
      elsif !name_parts(value).empty?
        person = ModsDisplay::Name::Person.new(:name => name_parts(value), :roles => roles)
      end
      ModsDisplay::Values.new(:label => displayLabel(value) || name_label(value), :values => [person]) if person
    end.compact
    collapse_fields(return_fields)
  end

  def to_html
    return nil if fields.empty? or @config.ignore?
    output = ""
    fields.each do |field|
      output << "<dt#{label_class} title='#{field.label}'>#{field.label}:</dt>"
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
      output << "</dd>"
    end
    output
  end

  private

  def name_label(element)
    if !has_role?(element) || is_primary?(element) || has_author_or_creator_roles?(element)
      "Author/Creator"
    else
      "Contributor"
    end
  end

  def has_role?(element)
    element.respond_to?(:role) and !element.role.empty?
  end

  def is_primary?(element)
    element.attributes["usage"].respond_to?(:value) and
    element.attributes["usage"].value == "primary"
  end

  def has_author_or_creator_roles?(element)
    begin
      ["author", "aut", "creator", "cre", ""].include?(element.role.roleTerm.text.downcase)
    rescue
      false
    end
  end

  def name_parts(element)
    output = ""
    output << [unqualified_name_parts(element),
               qualified_name_parts(element, "family"),
               qualified_name_parts(element, "given")].flatten.compact.join(", ")
    terms = qualified_name_parts(element, "termsOfAddress") 
    unless terms.empty?
      term_delimiter = ", "
      if name_part_begins_with_roman_numeral?(terms.first)
        term_delimiter = " "
      end
      output = [output, terms.join(", ")].flatten.compact.join(term_delimiter)
    end
    dates = qualified_name_parts(element, "date")
    unless dates.empty?
      output = [output, qualified_name_parts(element, "date")].flatten.compact.join(", ")
    end
    output
  end

  def unqualified_name_parts(element)
    element.namePart.map do |part|
      part.text unless part.attributes["type"]
    end.compact
  end

  def qualified_name_parts(element, type)
    element.namePart.map do |part|
      if part.attributes["type"].respond_to?(:value) and
         part.attributes["type"].value == type
           part.text
      end
    end.compact
  end

  def name_part_begins_with_roman_numeral?(part)
    first_part = part.split(/\s|,/).first.strip
    first_part.chars.all? do |char|
      ["I", "X", "C", "L", "V"].include? char
    end
  end

  def process_role(element)
    if element.role.length > 0 and element.role.roleTerm.length > 0
      if unencoded_role_term?(element)
        unencoded_role_term(element)
      else
        element.role.roleTerm.map do |term|
          if term.attributes["type"].respond_to?(:value) and
             term.attributes["type"].value == "code" and
             term.attributes["authority"].respond_to?(:value) and
             term.attributes["authority"].value == "marcrelator" and
             relator_codes.include?(term.text.strip)
               relator_codes[term.text.strip]
          end
        end.compact
      end
    end
  end

  def unencoded_role_term(element)
    roles = element.role.map do |role|
      role.roleTerm.find do |term|
        term.attributes["type"].respond_to?(:value) and
        term.attributes["type"].value == "text"
      end
    end.compact
    roles = element.role.map do |role|
      role.roleTerm.find do |term|
        !term.attributes["type"].respond_to?(:value)
      end
    end.compact if roles.empty?
    roles.map{|t| t.text.strip }
  end

  def unencoded_role_term?(element)
    element.role.roleTerm.any? do |term|
      !term.attributes["type"].respond_to?(:value) or
       term.attributes["type"].value == "text"
    end
  end

  def name_labels
    {"personal"   => "Author/Creator",
     "corporate"  => "Corporate author",
     "conference" => "Meeting",
     "family"     => "Family author"}
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