require "spec_helper"

def mods_display_note(mods_record)
  ModsDisplay::Note.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Note do
  before(:all) do
    @note = Stanford::Mods::Record.new.from_str("<mods><note>Note Field</note></mods>", false).note.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><note displayLabel='Special Label'>Note Field</note></mods>", false).note.first
    @sor_label = Stanford::Mods::Record.new.from_str("<mods><note type='statement of responsibility'>Note Field</note></mods>", false).note.first
    @type_label = Stanford::Mods::Record.new.from_str("<mods><note type='Some other Type'>Note Field</note></mods>", false).note.first
  end
  describe "label" do
    it "should have a default label" do
      mods_display_note(@note).label.should == "Note"
    end
    it "should use the displayLabel attribute when one is available" do
      mods_display_note(@display_label).label.should == "Special Label"
    end
    it "should use get a label from a list of translations" do
      mods_display_note(@sor_label).label.should == "Statement of Responsibility"
    end
    it "should use use the raw type attribute if one is present" do
      mods_display_note(@type_label).label.should == "Some other Type"
    end
  end  
  
end