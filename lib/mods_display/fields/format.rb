class ModsDisplay::Format < ModsDisplay::Field
  def fields
    return_fields = []
    if @values.respond_to?(:format) &&
       !@values.format.nil? &&
       !@values.format.empty?
      return_fields << ModsDisplay::Values.new(label: format_label,
                                               values: [decorate_formats(@values.format).join(', ')])
    end
    unless @values.physical_description.nil?
      @values.physical_description.each do |description|
        unless description.form.nil? || description.form.empty?
          return_fields << ModsDisplay::Values.new(label: displayLabel(description) || format_label,
                                                   values: [description.form.map { |f| f.text.strip }.uniq.join(', ')])
        end
        unless description.extent.nil? || description.extent.empty?
          return_fields << ModsDisplay::Values.new(label: displayLabel(description) || format_label,
                                                   values: [description.extent.map(&:text).join(', ')])
        end
      end
    end
    collapse_fields(return_fields)
  end

  private

  def decorate_formats(formats)
    formats.map do |format|
      "<span data-mods-display-format='#{self.class.format_class(format)}'>#{format}</span>"
    end
  end

  def self.format_class(format)
    return format if format.nil?
    format.strip.downcase.gsub(/\/|\\|\s+/, '_')
  end

  def format_label
    I18n.t('mods_display.format')
  end
end
