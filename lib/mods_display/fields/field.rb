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
          values: [value.text]
        )
      end
      collapse_fields(return_fields)
    end

    def label
      return nil if @values.nil?
      displayLabel(@values.first)
    end

    def to_html(view_context = ApplicationController.renderer)
      view_context.render ModsDisplay::FieldComponent.with_collection(fields, delimiter: delimiter), layout: false
    end

    def render_in(view_context)
      to_html(view_context)
    end

    private

    def delimiter
      nil
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
