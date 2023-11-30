# frozen_string_literal: true

module ModsDisplay
  class Field
    def initialize(values)
      @values = values
    end

    def fields
      return_fields = @values.map do |value|
        ModsDisplay::Values.new(
          label: displayLabel(value) || label,
          values: [element_text(value)],
          field: self
        )
      end
      collapse_fields(return_fields)
    end

    def label
      return nil if @values.nil?

      displayLabel(@values.first)
    end

    def to_html(view_context = ApplicationController.renderer)
      view_context.render ModsDisplay::FieldComponent.with_collection(fields, delimiter: delimiter), layout: false
    end

    def render_in(view_context)
      to_html(view_context)
    end

    private

    def delimiter
      nil
    end

    def displayLabel(element)
      return unless element.respond_to?(:attributes) &&
                    element.attributes['displayLabel'].respond_to?(:value)

      "#{element.attributes['displayLabel'].value}:"
    end

    def collapse_fields(display_fields)
      return display_fields if display_fields.length == 1

      display_fields.slice_when { |before, after| before.label != after.label }.map do |group|
        next group.first if group.length == 1

        ModsDisplay::Values.new(label: group.first.label, values: group.map(&:values).flatten(1))
      end
    end

    def element_text(element)
      element.xpath('.//text()').to_html.strip
    end

    # used for originInfo date fields, e.g. DateCreated, DateIssued ...
    def date_fields(date_symbol)
      return_fields = @values.map do |value|
        date_values = Stanford::Mods::Imprint.new(value).dates([date_symbol])
        next unless date_values.present?

        ModsDisplay::Values.new(
          label: I18n.t("mods_display.#{date_symbol.to_s.underscore}"),
          values: select_best_date(date_values),
          field: self
        )
      end.compact
      collapse_fields(return_fields)
    end

    # used for originInfo dates, e.g. for Imprint, DateCreated, DateIssued, etc.
    def select_best_date(dates)
      # ensure dates are unique with respect to their base values
      dates = dates.group_by(&:base_value).map do |_value, group|
        group.first if group.one?

        # if one of the duplicates wasn't encoded, use that one. see:
        # https://consul.stanford.edu/display/chimera/MODS+display+rules#MODSdisplayrules-3b.%3CoriginInfo%3E
        if group.reject(&:encoding).any?
          group.reject(&:encoding).first

        # otherwise just randomly pick the last in the group
        else
          group.last
        end
      end

      # if any single dates are already part of a range, discard them
      range_base_values = dates.select { |date| date.is_a?(Stanford::Mods::Imprint::DateRange) }
                               .map(&:base_values).flatten
      dates = dates.reject { |date| range_base_values.include?(date.base_value) }

      # output formatted dates with qualifiers, CE/BCE, etc.
      dates.map(&:qualified_value)
    end
  end
end
