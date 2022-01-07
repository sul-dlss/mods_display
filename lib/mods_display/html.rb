module ModsDisplay
  class HTML
    def initialize(xml)
      @stanford_mods = xml
      @xml = xml.mods_ng_xml
    end

    def title
      unless mods_field(@xml, :title).fields.empty?
        return mods_field(@xml, :title).fields.first.values
      end
      ''
    end

    # Need to figure out how to get the 1st title out of the list.
    # Maybe have a separate class that will omit the first tite natively
    # and replace the first key in the the fields list with that.
    def body
      output = '<dl>'
      body_fields = mods_display_fields.dup
      body_fields[0] = :subTitle
      body_fields.each do |field_key|
        field = mods_field(@xml, field_key)
        output << field.to_html unless field.nil? || field.to_html.nil?
      end
      output << '</dl>'
    end

    def to_html
      output = '<dl>'
      mods_display_fields.each do |field_key|
        field = mods_field(@xml, field_key)
        output << field.to_html unless field.nil? || field.to_html.nil?
      end
      output << '</dl>'
    end

    def method_missing(method_name, *args, &block)
      if to_s.respond_to?(method_name)
        to_html.send(method_name, *args, &block)
      elsif method_name == :subTitle || mods_display_fields.include?(method_name)
        field = mods_field(@xml, method_name)
        return field if (args.dig(0, :raw))
        field.fields
      else
        super
      end
    end

    private

    def mods_field(xml, field_key)
      if xml.respond_to?(mods_display_field_mapping[field_key])
        field = xml.send(mods_display_field_mapping[field_key])
        ModsDisplay.const_get(
          "#{field_key.slice(0, 1).upcase}#{field_key.slice(1..-1)}"
        ).new(field)
      elsif @stanford_mods.respond_to?(field_key)
        ModsDisplay.const_get(
          "#{field_key.slice(0, 1).upcase}#{field_key.slice(1..-1)}"
        ).new(@stanford_mods)
      end
    end

    def mods_display_fields
      [:title,
       :name,
       :language,
       :imprint,
       :resourceType,
       :genre,
       :form,
       :extent,
       :geo,
       :description,
       :cartographics,
       :abstract,
       :contents,
       :audience,
       :note,
       :contact,
       :collection,
       :nestedRelatedItem,
       :relatedItem,
       :subject,
       :identifier,
       :location,
       :accessCondition
      ]
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
