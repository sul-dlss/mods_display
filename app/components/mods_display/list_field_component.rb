module ModsDisplay
  class ListFieldComponent < ModsDisplay::FieldComponent
    def initialize(field:, list_html_attributes: {}, list_item_html_attributes: {}, **args)
      super(field: field, **args)

      @list_html_attributes = list_html_attributes
      @list_item_html_attributes = list_item_html_attributes
    end
  end
end
