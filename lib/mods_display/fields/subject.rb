# frozen_string_literal: true

module ModsDisplay
  class Subject < Field
    def fields
      return_fields = []
      @values.each do |value|
        return_values = []
        label = displayLabel(value) || I18n.t('mods_display.subject')
        return_text = []
        selected_subjects(value).each do |child|
          if respond_to?(:"process_#{child.name}")
            method_send = send(:"process_#{child.name}", child)
            return_text << method_send unless method_send.to_s.empty?
          elsif child.text.include?('--')
            return_text << child.text.split('--').map(&:strip)
          else
            return_text << child.text unless child.text.empty?
          end
        end
        return_values << return_text.flatten unless return_text.empty?
        return_fields << ModsDisplay::Values.new(label: label, values: return_values) unless return_values.empty?
      end
      collapse_fields return_fields
    end

    # Would really like to clean this up, but it works and is tested for now.
    def to_html(view_context = ApplicationController.renderer)
      component = ModsDisplay::FieldComponent.with_collection(
        fields,
        delimiter: '<br />'.html_safe,
        value_transformer: ->(value) { value.join(' > ') }
      )

      view_context.render component, layout: false
    end

    def process_hierarchicalGeographic(element)
      values_from_subjects(element)
    end

    def process_name(element)
      name = ModsDisplay::Name.new([element]).fields.first

      name&.values&.first
    end

    private

    def delimiter
      ' &gt; '
    end

    def values_from_subjects(element)
      return_values = []
      selected_subjects(element).each do |child|
        return_values << if child.text.include?('--')
                           child.text.split('--').map(&:strip)
                         else
                           child.text.strip
                         end
      end
      return_values
    end

    def selected_subjects(element = @value)
      element.children.reject do |child|
        omit_elements.include?(child.name.to_sym)
      end
    end

    def omit_elements
      %i[cartographics geographicCode text]
    end
  end
end
