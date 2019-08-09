module ModsDisplay
  class AccessCondition < Field
    LICENSES = {
      'cc-none' => { desc: '' },
      'cc-by' => {
        link: 'http://creativecommons.org/licenses/by/3.0/',
        desc: 'This work is licensed under a Creative Commons Attribution 3.0 Unported License'
      },
      'cc-by-sa' => {
        link: 'http://creativecommons.org/licenses/by-sa/3.0/',
        desc: 'This work is licensed under a Creative Commons Attribution-Share Alike 3.0 Unported License'
      },
      'cc-by-nd' => {
        link: 'http://creativecommons.org/licenses/by-nd/3.0/',
        desc: 'This work is licensed under a Creative Commons Attribution-No Derivative Works 3.0 Unported License'
      },
      'cc-by-nc' => {
        link: 'http://creativecommons.org/licenses/by-nc/3.0/',
        desc: 'This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License'
      },
      'cc-by-nc-sa' => {
        link: 'http://creativecommons.org/licenses/by-nc-sa/3.0/',
        desc: 'This work is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 Unported License'
      },
      'cc-by-nc-nd' => {
        link: 'http://creativecommons.org/licenses/by-nc-nd/3.0/',
        desc: 'This work is licensed under a Creative Commons Attribution-Noncommercial-No Derivative Works 3.0 Unported License'
      },
      'cc-pdm' => {
        link: 'http://creativecommons.org/publicdomain/mark/1.0/',
        desc: 'This work is in the public domain per Creative Commons Public Domain Mark 1.0'
      },
      'odc-odc-pddl' => {
        link: 'http://opendatacommons.org/licenses/pddl/',
        desc: 'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
      },
      'odc-pddl' => {
        link: 'http://opendatacommons.org/licenses/pddl/',
        desc: 'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
      },
      'odc-odc-by' => {
        link: 'http://opendatacommons.org/licenses/by/',
        desc: 'This work is licensed under a Open Data Commons Attribution License'
      },
      'odc-odc-odbl' => {
        link: 'http://opendatacommons.org/licenses/odbl/',
        desc: 'This work is licensed under a Open Data Commons Open Database License (ODbL)'
      }
    }.freeze

    def fields
      return_fields = @values.map do |value|
        ModsDisplay::Values.new(
          label: displayLabel(value) || access_label(value),
          values: [process_access_statement(value)]
        )
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
      matches = element.text.match(/^(?<code>.*) (?<type>.*):(?<description>.*)$/)
      code = matches[:code].downcase
      type = matches[:type].downcase
      description = license_description(code, type) || matches[:description]
      url = license_url(code, type)
      output = "<div class='#{code}-#{type}'>"
      output << if url
                  "<a href='#{url}'>#{description}</a>"
                else
                  description
                end
      output << '</div>'
    end

    def license_url(code, type)
      key = "#{code}-#{type}"
      return unless LICENSES.key?(key)

      LICENSES[key][:link]
    end

    def license_description(code, type)
      key = "#{code}-#{type}"
      return unless LICENSES.key?(key) && LICENSES[key][:desc]

      LICENSES[key][:desc]
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
end
