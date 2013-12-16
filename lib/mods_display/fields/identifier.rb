class ModsDisplay::Identifier < ModsDisplay::Field

  def fields
    return_fields = @values.map do |value|
      ModsDisplay::Values.new(:label => displayLabel(value) || identifier_label(value), :values => [value.text])
    end
    collapse_fields(return_fields)
  end

  private

  def identifier_label(element)
    if element.attributes["type"].respond_to?(:value)
      return identifier_labels[element.attributes["type"].value] || "#{element.attributes["type"].value}:"
    end
    I18n.t('mods_display.identifier')
  end

  def identifier_labels
    {"local"                     => I18n.t('mods_display.identifier'),
     "isbn"                      => I18n.t('mods_display.isbn'),
     "issn"                      => I18n.t('mods_display.issn'),
     "issn-l"                    => I18n.t('mods_display.issn'),
     "doi"                       => I18n.t('mods_display.doi'),
     "hdl"                       => I18n.t('mods_display.handle'),
     "isrc"                      => I18n.t('mods_display.isrc'),
     "ismn"                      => I18n.t('mods_display.ismn'),
     "issue number"              => I18n.t('mods_display.issue_number'),
     "lccn"                      => I18n.t('mods_display.lccn'),
     "oclc"                      => I18n.t('mods_display.oclc'),
     "matrix number"             => I18n.t('mods_display.matrix_number'),
     "music publisher"           => I18n.t('mods_display.music_publisher'),
     "music plate"               => I18n.t('mods_display.music_plate'),
     "sici"                      => I18n.t('mods_display.sici'),
     "upc"                       => I18n.t('mods_display.upc'),
     "videorecording identifier" => I18n.t('mods_display.videorecording_identifier'),
     "stock number"              => I18n.t('mods_display.stock_number')}
  end

end