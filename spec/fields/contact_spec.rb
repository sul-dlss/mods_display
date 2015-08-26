require "spec_helper"

def mods_display_contact(mods_record)
  ModsDisplay::Contact.new(mods_record, ModsDisplay::Configuration::Base.new, double("controller"))
end

describe ModsDisplay::Contact do
  before(:all) do
    @contact_note = Stanford::Mods::Record.new.from_str("<mods><note type='contact'>jdoe@example.com</note><note>Note Field</note></mods>", false).note
  end
  it "should only get contact fields" do
    fields = mods_display_contact(@contact_note).fields
    expect(fields.length).to eq(1)
    expect(fields.first.values).to include("jdoe@example.com")
  end
  it "should not get any non-contact fields" do
    fields = mods_display_contact(@contact_note).fields
    expect(fields.length).to eq(1)
    expect(fields.first.values).not_to include("Note Field")
  end
end
