class ModsDisplay::AccessCondition < ModsDisplay::Field

  def fields
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(:label => displayLabel(value) || access_label(value), :values => [process_access_statement(value)])
    end
    collapse_fields(return_fields)
  end

  private

  def process_access_statement(element)
    case normalize_type(element)
    when "copyright"
      copyright_statement(element)
    when "license"
      license_statement(element)
    else
      element.text
    end
  end

  def copyright_statement(element)
    element.text.gsub(/\(c\) copyright/i, "&copy;").gsub(/\(c\)/i, "&copy;")
  end

  def license_statement(element)
    element.text[/^(.*) (.*):(.*)$/]
    output = "<div class='#{[$1,$2].join('-').downcase}'>"
      if license_link($1, $2)
        output << "<a href='#{license_link($1, $2)}'>#{$3.strip}</a>"
      else
       output << $3.strip
      end
    output << "</div>"
  end

  def license_code_urls
    {"cc"  => "http://creativecommons.org/licenses/",
     "odc" => "http://opendatacommons.org/licenses/"}
  end

  def license_link(code, type)
    code = code.downcase
    if license_code_urls.has_key?(code)
      "#{license_code_urls[code]}#{type.downcase}#{"/#{@config.cc_license_version}/" if code == 'cc'}"
    end
  end

  def access_label(element)
    type = normalize_type(element)
    if access_labels.has_key?(type)
      return access_labels[type]
    end
    "Access condition"
  end

  def normalize_type(element)
    type = element.attributes["type"]
    if type.respond_to?(:value)
      return type.value.strip.gsub(/\s*/, "").downcase
    end
    ""
  end

  def access_labels
    {"useandreproduction"  => "Use and reproduction",
     "restrictiononaccess" => "Restriction on access",
     "copyright"           => "Copyright",
     "license"             => "License"
     }
  end
end