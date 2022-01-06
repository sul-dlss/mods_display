# encoding: utf-8
module ModsDisplay
  class Field
    def initialize(values)
      @values = values
    end

    def fields
      return_fields = @values.map do |value|
        ModsDisplay::Values.new(
          label: displayLabel(value) || label,
          values: [displayForm(@values) || value.text].flatten
        )
      end
      collapse_fields(return_fields)
    end

    def label
      return nil if @values.nil?
      displayLabel(@values.first)
    end

    def to_html(view_context = ApplicationController.renderer)
      view_context.render ModsDisplay::FieldComponent.with_collection(fields, delimiter: delimiter)
    end

    def render_in(view_context)
      to_html(view_context)
    end

    private

    def delimiter
      nil
    end

    def compact_and_join_with_delimiter(values, delimiter)
      compact_values = values.compact.reject { |v| v.strip.empty? }
      return compact_values.join(delimiter) if compact_values.length == 1 ||
                                               !ends_in_terminating_punctuation?(delimiter)
      compact_values.each_with_index.map do |value, i|
        if (compact_values.length - 1) == i || # last item?
           ends_in_terminating_punctuation?(value)
          value << ' '
        else
          value << delimiter
        end
      end.join.strip
    end

    def process_bc_ad_dates(date_fields)
      date_fields.map do |date_field|
        case
        when date_is_bc_edtf?(date_field)
          year = date_field.text.strip.gsub(/^-0*/, '').to_i + 1
          date_field.content = "#{year} B.C."
        when date_is_ad?(date_field)
          date_field.content = "#{date_field.text.strip.gsub(/^0*/, '')} A.D."
        end
        date_field
      end
    end

    def date_is_bc_edtf?(date_field)
      date_field.text.strip.start_with?('-') && date_is_edtf?(date_field)
    end

    def date_is_ad?(date_field)
      date_field.text.strip.gsub(/^0*/, '').length < 4
    end

    def date_is_edtf?(date_field)
      field_is_encoded?(date_field, 'edtf')
    end

    def field_is_encoded?(field, encoding)
      field.attributes['encoding'] &&
        field.attributes['encoding'].respond_to?(:value) &&
        field.attributes['encoding'].value.downcase == encoding
    end

    def ends_in_terminating_punctuation?(value)
      value.strip.end_with?('.', ',', ':', ';')
    end

    def displayForm(element)
      return element unless element # basically return nil
      display = element.children.find { |c| c.name == 'displayForm' }
      return display.text if display
    end

    def displayLabel(element)
      return unless element.respond_to?(:attributes) &&
                    element.attributes['displayLabel'].respond_to?(:value)
      "#{element.attributes['displayLabel'].value}:"
    end

    def collapse_fields(display_fields)
      return display_fields if display_fields.length == 1

      display_fields.slice_when { |before, after| before.label != after.label }.map do |group|
        next group.first if group.length == 1

        ModsDisplay::Values.new(label: group.first.label, values: group.map(&:values).flatten)
      end
    end
  end
end
