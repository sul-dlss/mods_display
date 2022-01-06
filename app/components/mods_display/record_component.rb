module ModsDisplay
  class RecordComponent < ViewComponent::Base
    DEFAULT_FIELDS = [
      :subTitle,
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
      :location
      # :accessCondition
    ].freeze

    with_collection_parameter :record

    def initialize(record:, fields: DEFAULT_FIELDS)
      super

      @record = record
      @fields = fields
    end
  end
end
