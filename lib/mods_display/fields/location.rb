# frozen_string_literal: true

module ModsDisplay
  class Location < Field
    def fields
      return_fields = []
      @stanford_mods_elements.each do |location_element|
        location_element.children.each do |child|
          next unless location_field_keys.include?(child.name.to_sym)

          if child.name.to_sym == :url
            loc_label = displayLabel(location_element) || I18n.t('mods_display.location')
            value = "<a href='#{element_text(child)}'>#{(displayLabel(child) || element_text(child)).gsub(/:$/,
                                                                                                          '')}</a>"
          else
            loc_label = location_label(child) || displayLabel(location_element) || I18n.t('mods_display.location')
            value = element_text(child)
          end
          return_fields << ModsDisplay::Values.new(
            label: loc_label || displayLabel(location_element) || I18n.t('mods_display.location'),
            values: [value]
          )
        end
      end
      collapse_fields(return_fields)
    end

    private

    def location_field_keys
      %i[physicalLocation url shelfLocator holdingSimple holdingExternal]
    end

    def location_label(element)
      if displayLabel(element)
        displayLabel(element)
      elsif element.attributes['type'].respond_to?(:value) && location_labels.key?(element.attributes['type'].value)
        location_labels[element.attributes['type'].value]
      end
    end

    def location_labels
      { 'repository' => I18n.t('mods_display.repository') }
    end
  end
end
