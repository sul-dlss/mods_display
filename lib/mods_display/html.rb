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

    def render_in(view_context)
      body(view_context)
    end

    # Need to figure out how to get the 1st title out of the list.
    # Maybe have a separate class that will omit the first tite natively
    # and replace the first key in the the fields list with that.
    def body(view_context = ApplicationController.renderer)
      view_context.render ModsDisplay::RecordComponent.new(record: self)
    end

    # @deprecated
    def to_html(view_context = ApplicationController.renderer)
      fields = [:title] + ModsDisplay::RecordComponent::DEFAULT_FIELDS - [:subTitle]
      view_context.render ModsDisplay::RecordComponent.new(record: self, fields: fields)
    end

    def method_missing(method_name, *args, &block)
      if to_s.respond_to?(method_name)
        to_html.send(method_name, *args, &block)
      elsif mods_display_field_mapping.include?(method_name)
        field = mods_field(method_name)
        return field if (args.dig(0, :raw))
        field.fields
      else
        super
      end
    end

    def mods_field(key)
      raise ArgumentError unless mods_display_field_mapping[key] && @xml.respond_to?(mods_display_field_mapping[key])

      field = @xml.send(mods_display_field_mapping[key])
      mods_field_class(key).new(field)
    end

    private

    def mods_field_class(key)
      ModsDisplay.const_get(
        "#{key.slice(0, 1).upcase}#{key.slice(1..-1)}"
      )
    end

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
