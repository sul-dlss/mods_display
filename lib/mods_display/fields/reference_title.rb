# frozen_string_literal: true

module ModsDisplay
  class ReferenceTitle < Field
    def fields
      # Reference title is a composite field that includes parts from elsewhere in the record.
      return [] unless @values.present?

      return_fields = [ModsDisplay::Values.new(label: displayLabel(@values.first) || label, values: [title_value].compact)]
      collapse_fields(return_fields)
    end

    private

    def root
      @root ||= @values.first.document.root
    end

    def displayLabel(element)
      super(element) || I18n.t('mods_display.referenced_by')
    end

    def title_value
      [@values,
       root.xpath('mods:originInfo/mods:dateOther', mods: MODS_NS),
       root.xpath('mods:part/mods:detail/mods:number', mods: MODS_NS),
       root.xpath('mods:note', mods: MODS_NS)].flatten.compact.map!(&:text).map!(&:strip).join(' ').presence
    end
  end
end
