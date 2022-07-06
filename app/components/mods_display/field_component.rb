# frozen_string_literal: true

module ModsDisplay
  class FieldComponent < ViewComponent::Base
    with_collection_parameter :field

    def initialize(field:, delimiter: nil, label_html_attributes: {}, value_html_attributes: {}, value_transformer: nil)
      super

      @field = field
      @delimiter = delimiter
      @value_transformer = value_transformer
      @label_html_attributes = label_html_attributes
      @value_html_attributes = value_html_attributes
    end

    def render?
      @field.values.any?(&:present?)
    end

    def format_value(value)
      if @value_transformer
        @value_transformer.call(value)
      else
        helpers.format_mods_html(value, field: @field)
      end
    end
  end
end
