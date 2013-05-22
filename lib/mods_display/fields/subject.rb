class ModsDisplay::Subject < ModsDisplay::Field
  
  def fields
    return_values = []
    selected_subjects.each do |child|
      if self.respond_to?(:"process_#{child.name}")
        return_values << self.send(:"process_#{child.name}", child)
      else
        if child.text.include?("--")
          return_values << child.text.split("--").map{|t| t.strip }
        else
          return_values << child.text
        end
      end
    end
    return [] if return_values.empty?
    [ModsDisplay::Values.new(:label => "Subject", :values => return_values.flatten)]
  end
  
  # Would really like to clean this up, but it works and is tested for now.
  def to_html
    return nil if fields.empty?
    output = ""
    fields.each do |field|
      output << "<dt#{label_class}>#{field.label}:</dt>"
      output << "<dd#{value_class}>"
        if @config.link
          buffer = []
          subs = []
          field.values.each do |val|
            if val.is_a?(ModsDisplay::Name::Person)
              buffer << val.name
            else
              buffer << val
            end
            if @config.hierarchical_link
              if val.is_a?(ModsDisplay::Name::Person)
                txt = link_to_value(val.name, buffer.join(' '))
                txt << " (#{val.role})" if val.role
                subs << txt
              else
                subs << link_to_value(val, buffer.join(' '))
              end
            else
              if val.is_a?(ModsDisplay::Name::Person)
                txt = link_to_value(val.name)
                txt << " (#{val.role})" if val.role
                subs << txt
              else
                subs << link_to_value(val.to_s)
              end
            end
          end
          output << subs.join(@config.delimiter)
        else
          output << field.values.join(@config.delimiter)
        end
      output << "</dd>"
    end
    output
  end

  def process_hierarchicalGeographic(element)
    values_from_subjects(element)
  end
  
  def process_name(element)
    ModsDisplay::Name.new(element, @config, @klass).fields.first.values.first
  end
  
  private

  def values_from_subjects(element)
    return_values = []
    selected_subjects(element).each do |child|
      if child.text.include?("--")
        return_values << child.text.split("--").map{|t| t.strip }
      else
        return_values << child.text.strip
      end
    end
    return_values
  end
  
  def selected_subjects(element=@value)
    element.children.select do |child|
      !omit_elements.include?(child.name.to_sym)
    end
  end
  
  def omit_elements
    [:cartographics, :geographicCode, :text]
  end
  
end