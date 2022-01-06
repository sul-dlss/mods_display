module ModsDisplay
  class FieldComponent < ViewComponent::Base
    with_collection_parameter :field

    def initialize(field:, delimiter: nil, label_html_attributes: {}, value_html_attributes: {}, &value_block)
      @field = field
      @delimiter = delimiter
      @value_block = value_block
      @label_html_attributes = label_html_attributes
      @value_html_attributes = value_html_attributes
    end

    def render?
      @field.values.any?(&:present?)
    end

    def format(value)
      if @value_block
        @value_block.call(value)
      else
        helpers.link_urls_and_email(value)
      end
    end
  end
end
