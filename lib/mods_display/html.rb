# frozen_string_literal: true

module ModsDisplay
  class HTML
    MODS_DISPLAY_FIELD_MAPPING = {
      title: :title_info,
      subTitle: :title_info,
      referenceTitle: :title_info,
      name: :plain_name,
      resourceType: :typeOfResource,
      genre: :genre,
      form: :physical_description,
      extent: :physical_description,
      geo: :extension,
      copyrightDate: :origin_info,
      dateCaptured: :origin_info,
      dateCreated: :origin_info,
      dateIssued: :origin_info,
      dateModified: :origin_info,
      dateValid: :origin_info,
      edition: :origin_info,
      frequency: :origin_info,
      imprint: :origin_info,
      issuance: :origin_info,
      place: :origin_info,
      publisher: :origin_info,
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
      accessCondition: :accessCondition
    }.freeze

    def initialize(mods)
      @mods = mods
      @xml = mods.mods_ng_xml
    end

    attr_reader :xml

    def title
      title_fields = mods_field(:title).fields
      title_fields.empty? ? '' : title_fields.first.values
    end

    def render_in(view_context)
      body(view_context)
    end

    # Need to figure out how to get the 1st title out of the list.
    # Maybe have a separate class that will omit the first title natively
    # and replace the first key in the the fields list with that.
    def body(view_context = ApplicationController.renderer, html_attributes: {}, component: ModsDisplay::RecordComponent)
      view_context.render component.new(record: self, html_attributes: html_attributes), layout: false
    end

    # @deprecated
    def to_html(view_context = ApplicationController.renderer)
      fields = [:title] + ModsDisplay::RecordComponent::DEFAULT_FIELDS - [:subTitle]
      view_context.render ModsDisplay::RecordComponent.new(record: self, fields: fields), layout: false
    end

    MODS_DISPLAY_FIELD_MAPPING.each_key do |key|
      next if key == :title

      define_method(key) do |raw: false, **field_args|
        field = mods_field(key, field_args: field_args)
        next field if raw

        field.fields
      end
    end

    def mods_field(key, field_args: {})
      raise ArgumentError unless MODS_DISPLAY_FIELD_MAPPING[key] && @xml.respond_to?(MODS_DISPLAY_FIELD_MAPPING[key])

      field = @xml.public_send(MODS_DISPLAY_FIELD_MAPPING[key])
      mods_field_class(key).new(field, **field_args)
    end

    private

    def mods_field_class(key)
      ModsDisplay.const_get(
        "#{key.slice(0, 1).upcase}#{key.slice(1..-1)}"
      )
    end
  end
end
