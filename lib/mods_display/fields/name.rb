class ModsDisplay::Name < ModsDisplay::Field

  def fields
    return_values = []
    current_label = nil
    prev_label = nil
    buffer = []
    @value.each_with_index do |val, index|
      current_label = (displayLabel(val) || name_label(val))
      people = []
      role = nil
      if val.role.length > 0 and val.role.roleTerm.length > 0
        role = val.role.roleTerm.find do |term|
          term.attributes["type"].respond_to?(:value) and
          term.attributes["type"].value == "text"
        end
      end
      if val.displayForm.length > 0
        people << ModsDisplay::Name::Person.new(:name => val.displayForm.text, :role => role)
      else
        name_parts = val.namePart.map do |name_part|
          name_part.text
        end.join(", ")
        people << ModsDisplay::Name::Person.new(:name => name_parts, :role => role)
      end
      if @value.length == 1
        return_values << ModsDisplay::Values.new(:label => current_label, :values => people.flatten)
      elsif index == (@value.length-1)
        # need to deal w/ when we have a last element but we have separate labels in the buffer.
        if current_label != prev_label
          return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
          return_values << ModsDisplay::Values.new(:label => current_label, :values => people.flatten)
        else
          buffer << people
          return_values << ModsDisplay::Values.new(:label => current_label, :values => buffer.flatten)
        end
      elsif prev_label and (current_label != prev_label)
        return_values << ModsDisplay::Values.new(:label => prev_label, :values => buffer.flatten)
        buffer = []
      end
      buffer << people
      prev_label = current_label
    end
    return_values
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

  def name_label(element)
    if element.attributes.has_key?("type") && name_labels.has_key?(element.attributes["type"].value)
      return name_labels[element.attributes["type"].value]
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