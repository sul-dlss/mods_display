# frozen_string_literal: true

def copyright_date_fields(mods_text)
  ModsDisplay::CopyrightDate.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  ).fields
end

def copyright_date_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  copyright_date_fields(mods_text).map(&:values).flatten
end

def date_captured_fields(mods_text)
  ModsDisplay::DateCaptured.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  ).fields
end

def date_captured_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  date_captured_fields(mods_text).map(&:values).flatten
end

def date_created_fields(mods_text)
  ModsDisplay::DateCreated.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  ).fields
end

def date_created_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  date_created_fields(mods_text).map(&:values).flatten
end

def date_issued_fields(mods_text)
  ModsDisplay::DateIssued.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  ).fields
end

def date_issued_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  date_issued_fields(mods_text).map(&:values).flatten
end

def date_modified_fields(mods_text)
  ModsDisplay::DateModified.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  ).fields
end

def date_modified_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  date_modified_fields(mods_text).map(&:values).flatten
end

def date_valid_fields(mods_text)
  ModsDisplay::DateValid.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  ).fields
end

def date_valid_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  date_valid_fields(mods_text).map(&:values).flatten
end
