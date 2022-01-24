# frozen_string_literal: true

require 'spec_helper'

def mods_display_contact(mods_record)
  ModsDisplay::Contact.new(mods_record)
end

describe ModsDisplay::Contact do
  before(:all) do
    @contact_note = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><note type='contact'>jdoe@example.com</note><note>Note Field</note></mods>"
    ).note
  end

  it 'onlies get contact fields' do
    fields = mods_display_contact(@contact_note).fields
    expect(fields.length).to eq(1)
    expect(fields.first.values).to include('jdoe@example.com')
  end

  it 'does not get any non-contact fields' do
    fields = mods_display_contact(@contact_note).fields
    expect(fields.length).to eq(1)
    expect(fields.first.values).not_to include('Note Field')
  end
end
