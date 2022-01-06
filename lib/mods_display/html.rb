module ModsDisplay
  class HTML
    def initialize(xml)
      @stanford_mods = xml
      @xml = xml.mods_ng_xml
    end

    def title
      unless mods_field(:title).fields.empty?
        return mods_field(:title).fields.first.values
      end
      ''
    end

    # Need to figure out how to get the 1st title out of the list.
    # Maybe have a separate class that will omit the first tite natively
    # and replace the first key in the the fields list with that.
    def body
      ApplicationController.renderer.render ModsDisplay::RecordComponent.new(record: self)
    end

    # @deprecated
    def to_html
      fields = [:title] + ModsDisplay::RecordComponent::DEFAULT_FIELDS - [:subTitle]
      ApplicationController.renderer.render ModsDisplay::RecordComponent.new(record: self, fields: fields)
    end

    def method_missing(method_name, *args, &block)
      if to_s.respond_to?(method_name)
        to_html.send(method_name, *args, &block)
      elsif method_name == :subTitle || mods_display_field_mapping.include?(method_name)
        field = mods_field(method_name)
        return field if (args.dig(0, :raw))
        field.fields
      else
        super
      end
    end

    def mods_field(field_key)
      if @xml.respond_to?(mods_display_field_mapping[field_key])
        field = @xml.send(mods_display_field_mapping[field_key])
        ModsDisplay.const_get(
          "#{field_key.slice(0, 1).upcase}#{field_key.slice(1..-1)}"
        ).new(field)
      elsif @stanford_mods.respond_to?(field_key)
        ModsDisplay.const_get(
          "#{field_key.slice(0, 1).upcase}#{field_key.slice(1..-1)}"
        ).new(@stanford_mods)
      end
    end

    private

    def mods_display_field_mapping
      { title: :title_info,
        subTitle: :title_info,
        name: :plain_name,
        resourceType: :typeOfResource,
        genre: :genre,
        form: :physical_description,
        extent: :physical_description,
        geo: :extension,
        imprint: :origin_info,
        language: :language,
        description: :physical_description,
        cartographics: :subject,
        abstract: :abstract,
        contents: :tableOfContents,
        audience: :targetAudience,
        note: :note,
        contact: :note,
        collection: :related_item,
        nestedRelatedItem: :related_item,
        relatedItem: :related_item,
        subject: :subject,
        identifier: :identifier,
        location: :location,
        accessCondition: :accessCondition }
    end

    def field_key_translation
      { subTitle: :sub_title,
        resourceType: :resource_type,
        relatedItem: :related_item,
        accessCondition: :access_condition,
        nestedRelatedItem: :nested_related_item
      }
    end
  end
end
