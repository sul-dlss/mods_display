class ModsDisplay::Name < ModsDisplay::Field

  def fields
    return_values = []
    role = nil
    if @value.role.length > 0 and @value.role.roleTerm.length > 0
      role = @value.role.roleTerm.find do |term|
        term.attributes["type"].respond_to?(:value) and
        term.attributes["type"].value == "text"
      end
    end
    if @value.displayForm.length > 0
      return_values << ModsDisplay::Name::Person.new(:name => @value.displayForm.text, :role => role)
    else
      name_parts = @value.namePart.map do |name_part|
        name_part.text
      end.join(", ")
      return_values << ModsDisplay::Name::Person.new(:name => name_parts, :role => role)
    end
    [ModsDisplay::Values.new(:label => label || name_label, :values => return_values)]
  end

  def to_html
    return nil if fields.empty?
    output = ""
    fields.each do |field|
      output << "<dt#{label_class} title='#{field.label}'>#{field.label}:</dt>"
      output << "<dd#{value_class}>"
        output << field.values.map do |val|
          if @config.link
            txt = link_to_value(val.name)
            txt << " (#{val.role})" if val.role
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

  def name_label
    if @value.attributes.has_key?("type") && name_labels.has_key?(@value.attributes["type"].value)
      return name_labels[@value.attributes["type"].value]
    end
    "Creator/Contributor"
  end

  def name_labels
    {"personal"   => "Author/Creator",
     "corporate"  => "Corporate Author",
     "conference" => "Meeting",
     "family"     => "Family Author"}
  end
  
  class Person
    attr_accessor :name, :role
    def initialize(data)
      @name = data[:name]
      @role = data[:role] ? data[:role].text : nil
    end
    
    def to_s
      text = @name
      text << " (#{@role})" if @role
      text
    end
  end

end