class ModsDisplay::AccessCondition < ModsDisplay::Field
  def fields
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(label: displayLabel(value) || access_label(value), values: [process_access_statement(value)])
    end
    collapse_fields(return_fields)
  end

  private

  def process_access_statement(element)
    case normalize_type(element)
    when 'copyright'
      copyright_statement(element)
    when 'license'
      license_statement(element)
    else
      element.text
    end
  end

  def copyright_statement(element)
    element.text.gsub(/\(c\) copyright/i, '&copy;').gsub(/\(c\)/i, '&copy;')
  end

  def license_statement(element)
    element.text[/^(.*) (.*):(.*)$/]
    output = "<div class='#{[Regexp.last_match(1), Regexp.last_match(2)].join('-').downcase}'>"
    if license_link(Regexp.last_match(1), Regexp.last_match(2))
      output << "<a href='#{license_link(Regexp.last_match(1), Regexp.last_match(2))}'>#{Regexp.last_match(3).strip}</a>"
    else
      output << Regexp.last_match(3).strip
    end
    output << '</div>'
  end

  def license_code_urls
    { 'cc'  => 'http://creativecommons.org/licenses/',
      'odc' => 'http://opendatacommons.org/licenses/' }
  end

  def license_link(code, type)
    code = code.downcase
    if license_code_urls.key?(code)
      "#{license_code_urls[code]}#{type.downcase}#{"/#{@config.cc_license_version}/" if code == 'cc'}"
    end
  end

  def access_label(element)
    type = normalize_type(element)
    return access_labels[type] if access_labels.key?(type)
    I18n.t('mods_display.access_condition')
  end

  def normalize_type(element)
    type = element.attributes['type']
    return type.value.strip.gsub(/\s*/, '').downcase if type.respond_to?(:value)
    ''
  end

  def access_labels
    { 'useandreproduction'  => I18n.t('mods_display.use_and_reproduction'),
      'restrictiononaccess' => I18n.t('mods_display.restriction_on_access'),
      'copyright'           => I18n.t('mods_display.copyright'),
      'license'             => I18n.t('mods_display.license')
     }
  end
end
