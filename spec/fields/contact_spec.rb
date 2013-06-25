require "spec_helper"

def mods_display_contact(mods_record)
  ModsDisplay::Contact.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Contact do
  before(:all) do
    @contact_note = Stanford::Mods::Record.new.from_str("<mods><note type='contact'>jdoe@example.com</note><note>Note Field</note></mods>", false).note
  end
  it "should only get contact fields" do
    fields = mods_display_contact(@contact_note).fields
    fields.length.should == 1
    fields.first.values.should include("jdoe@example.com")
  end
  it "should not get any non-contact fields" do
    fields = mods_display_contact(@contact_note).fields
    fields.length.should == 1
    fields.first.values.should_not include("Note Field")
  end
end
