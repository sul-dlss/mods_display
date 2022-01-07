module ModsDisplay
  class ListFieldComponent < ModsDisplay::FieldComponent
    def initialize(list_html_attributes: {}, list_item_html_attributes: {}, **args)
      super(**args)

      @list_html_attributes = list_html_attributes
      @list_item_html_attributes = list_item_html_attributes
    end
  end
end
