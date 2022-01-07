module ModsDisplay
  class Subject < Field
    def fields
      return_fields = []
      @values.each do |value|
        return_values = []
        label = displayLabel(value) || I18n.t('mods_display.subject')
        return_text = []
        selected_subjects(value).each do |child|
          if self.respond_to?(:"process_#{child.name}")
            method_send = send(:"process_#{child.name}", child)
            return_text << method_send unless method_send.to_s.empty?
          else
            if child.text.include?('--')
              return_text << child.text.split('--').map(&:strip)
            else
              return_text << child.text unless child.text.empty?
            end
          end
        end
        return_values << return_text.flatten unless return_text.empty?
        unless return_values.empty?
          return_fields << ModsDisplay::Values.new(label: label, values: return_values)
        end
      end
      collapse_subjects return_fields
    end

    # Would really like to clean this up, but it works and is tested for now.
    def to_html
      component = ModsDisplay::FieldComponent.with_collection(
        fields,
        delimiter: '<br />'.html_safe,
        value_transformer: ->(value) { value.join(' > ') }
      )

      ApplicationController.renderer.render component
    end

    def process_hierarchicalGeographic(element)
      values_from_subjects(element)
    end

    def process_name(element)
      name = ModsDisplay::Name.new([element]).fields.first

      name.values.first if name
    end

    private

    def delimiter
      ' &gt; '
    end

    def values_from_subjects(element)
      return_values = []
      selected_subjects(element).each do |child|
        if child.text.include?('--')
          return_values << child.text.split('--').map(&:strip)
        else
          return_values << child.text.strip
        end
      end
      return_values
    end

    def selected_subjects(element = @value)
      element.children.select do |child|
        !omit_elements.include?(child.name.to_sym)
      end
    end

    def omit_elements
      [:cartographics, :geographicCode, :text]
    end

    # Providing subject specific collapsing method so we can
    # collapse the labels w/o flattening all the subject fields.
    def collapse_subjects(display_fields)
      return_values = []
      current_label = nil
      prev_label = nil
      buffer = []
      display_fields.each_with_index do |field, index|
        current_label = field.label
        current_values = field.values
        if display_fields.length == 1
          return_values << ModsDisplay::Values.new(label: current_label, values: current_values)
        elsif index == (display_fields.length - 1)
          # need to deal w/ when we have a last element but we have separate labels in the buffer.
          if current_label != prev_label
            return_values << ModsDisplay::Values.new(label: prev_label, values: [buffer.flatten(1)])
            return_values << ModsDisplay::Values.new(label: current_label, values: current_values)
          else
            buffer.concat(current_values)
            return_values << ModsDisplay::Values.new(label: current_label, values: buffer.flatten(0))
          end
        elsif prev_label && (current_label != prev_label)
          return_values << ModsDisplay::Values.new(label: prev_label, values: buffer.flatten(0))
          buffer = []
        end
        buffer.concat(current_values)
        prev_label = current_label
      end
      return_values
    end
  end
end
