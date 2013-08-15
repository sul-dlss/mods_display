class ModsDisplay::Imprint < ModsDisplay::Field

  def fields
    return_fields = []
    @values.each do |value|
      if imprint_display_form(value)
        return_fields << imprint_display_form(value)
      else
        edition = nil
        place = nil
        publisher = nil
        placePub = nil
        edition = value.edition.map do |e|
          e.text unless e.text.strip.empty?
        end.compact.join(" ").strip
        place = value.place.map do |p|
          p.text unless p.text.strip.empty?
        end.compact.join(" : ").strip unless value.place.text.strip.empty?
        publisher = value.publisher.map do |p|
          p.text unless p.text.strip.empty?
        end.compact.join(" : ").strip unless value.publisher.text.strip.empty?
        parts = ["dateIssued", "dateOther"].map do |date_field_name|
          if value.respond_to?(date_field_name.to_sym)
            parse_dates(value.send(date_field_name.to_sym))
          end
        end.flatten.map do |date|
          date.strip unless date.strip.empty?
        end.compact.join(", ")
        edition = nil if edition.strip.empty?
        parts = nil if parts.strip.empty?
        placePub = [place, publisher].compact.join(" : ")
        placePub = nil if placePub.strip.empty?
        editionPlace = [edition, placePub].compact.join(" - ")
        editionPlace = nil if editionPlace.strip.empty?
        unless [editionPlace, parts].compact.join(", ").strip.empty?
          return_fields << ModsDisplay::Values.new(:label => displayLabel(value) || "Imprint", :values => [[editionPlace, parts].compact.join(", ")])
        end
        if dates(value).length > 0
          return_fields.concat(dates(value))
        end
        if other_pub_info(value).length > 0
          other_pub_info(value).each do |pub_info|
            return_fields << ModsDisplay::Values.new(:label => displayLabel(value) || pub_info_labels[pub_info.name.to_sym], :values => [pub_info.text.strip])
          end
        end
      end
    end
    collapse_fields(return_fields)
  end
  def dates(element)
    date_field_keys.map do |date_field|
      if element.respond_to?(date_field)
        elements = element.send(date_field)
        unless elements.empty?
          ModsDisplay::Values.new(:label => displayLabel(element) || pub_info_labels[elements.first.name.to_sym], :values => parse_dates(elements))
        end
      end
    end.compact
  end
  def parse_dates(date_field)
    apply_date_qualifier_decoration dedup_dates join_date_ranges date_field
  end
  def join_date_ranges(date_fields)
    if dates_are_range?(date_fields)
      start_date = date_fields.find{|d| d.attributes["point"] && d.attributes["point"].value == "start"}
      end_date = date_fields.find{|d| d.attributes["point"] && d.attributes["point"].value == "end"}
      date_fields.map do |date|
        date = date.clone # clone the date object so we don't append the same one
        if normalize_date(date.text) == start_date.text
          date.content = [start_date.text, end_date.text].join("-")
          date
        elsif normalize_date(date.text) != end_date.text
          date
        end
      end.compact
    elsif dates_are_open_range?(date_fields)
      start_date = date_fields.find{|d| d.attributes["point"] && d.attributes["point"].value == "start"}
      date_fields.map do |date|
        date = date.clone # clone the date object so we don't append the same one
        if date.text == start_date.text
          date.content = "#{start_date.text}-"
        end
        date
      end
    else
      date_fields
    end
  end
  def apply_date_qualifier_decoration(date_fields)
    return_fields = date_fields.map do |date|
      date = date.clone
      if date_is_approximate?(date)
        date.content = "[ca. #{date.text}]"
      elsif date_is_questionable?(date)
        date.content = "[#{date.text}?]"
      elsif date_is_inferred?(date)
        date.content = "[#{date.text}]"
      end
      date
    end
    return_fields.map{|d| d.text }
  end
  def date_is_approximate?(date_field)
    date_field.attributes["qualifier"] and
    date_field.attributes["qualifier"].respond_to?(:value) and
    date_field.attributes["qualifier"].value == "approximate"
  end
  def date_is_questionable?(date_field)
    date_field.attributes["qualifier"] and
    date_field.attributes["qualifier"].respond_to?(:value) and
    date_field.attributes["qualifier"].value == "questionable"
  end
  def date_is_inferred?(date_field)
    date_field.attributes["qualifier"] and
    date_field.attributes["qualifier"].respond_to?(:value) and
    date_field.attributes["qualifier"].value == "inferred"
  end
  def dates_are_open_range?(date_fields)
    date_fields.any? do |field|
      field.attributes["point"] and
      field.attributes["point"].respond_to?(:value) and
      field.attributes["point"].value == "start"
    end and !date_fields.any? do |field|
      field.attributes["point"] and
      field.attributes["point"].respond_to?(:value) and
      field.attributes["point"].value == "end"
    end
  end
  def dates_are_range?(date_fields)
    attributes = date_fields.map do |date|
      if date.attributes["point"].respond_to?(:value)
        date.attributes["point"].value
      end
    end
    attributes.include?("start") and
    attributes.include?("end")
  end
  def dedup_dates(date_fields)
    date_text = date_fields.map{|d| normalize_date(d.text) }
    if date_text != date_text.uniq
      if date_fields.find{ |d| d.attributes["qualifier"].respond_to?(:value) }
        [date_fields.find{ |d| d.attributes["qualifier"].respond_to?(:value) }]
      elsif date_fields.find{ |d| !d.attributes["encoding"] }
        [date_fields.find{ |d| !d.attributes["encoding"] }]
      else
        [date_fields.first]
      end
    else
      date_fields
    end
  end
  def normalize_date(date)
    date.strip.gsub(/^\s*\[*ca\.\s*|\[|\]|\?/, "")
  end
  def other_pub_info(element)
    element.children.select do |child|
      pub_info_parts.include?(child.name.to_sym)
    end
  end
  
  def imprint_display_form(element)
    display_form = element.children.find do |child|
      child.name == "displayForm"
    end
    ModsDisplay::Values.new(:label => displayLabel(element) || "Imprint", :values => [display_form.text]) if display_form
  end

  private

  def pub_info_parts
    [:issuance, :frequency]
  end

  def date_field_keys
    [:dateCreated, :dateCaptured, :dateValid, :dateModified, :copyrightDate]
  end

  def pub_info_labels
    {:dateCreated   => "Date created",
     :dateCaptured  => "Date captured",
     :dateValid     => "Date valid",
     :dateModified  => "Date modified",
     :copyrightDate => "Copyright date",
     :issuance      => "Issuance",
     :frequency     => "Frequency"
    }
  end

end