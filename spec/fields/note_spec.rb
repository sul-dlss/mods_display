require "spec_helper"

def mods_display_note(mods_record)
  ModsDisplay::Note.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Note do
  before(:all) do
    @note = Stanford::Mods::Record.new.from_str("<mods><note>Note Field</note></mods>", false).note
    @display_label = Stanford::Mods::Record.new.from_str("<mods><note displayLabel='Special Label'>Note Field</note></mods>", false).note
    @sor_label = Stanford::Mods::Record.new.from_str("<mods><note type='statement of responsibility'>Note Field</note></mods>", false).note
    @type_label = Stanford::Mods::Record.new.from_str("<mods><note type='Some other Type'>Note Field</note></mods>", false).note
    @complex_label = Stanford::Mods::Record.new.from_str("<mods><note>Note Field</note><note>2nd Note Field</note><note type='statement of responsibility'>SoR</note><note>Another Note</note></mods>", false).note
  end
  describe "label" do
    it "should have a default label" do
      mods_display_note(@note).fields.first.label.should == "Note"
    end
    it "should use the displayLabel attribute when one is available" do
      mods_display_note(@display_label).fields.first.label.should == "Special Label"
    end
    it "should use get a label from a list of translations" do
      mods_display_note(@sor_label).fields.first.label.should == "Statement of responsibility"
    end
    it "should use use the raw type attribute if one is present" do
      mods_display_note(@type_label).fields.first.label.should == "Some other Type"
    end
  end
  
  describe "fields" do
    it "should handle single values" do
      fields = mods_display_note(@note).fields
      fields.length.should == 1
      fields.first.values.should == ["Note Field"]
    end
    it "should handle complex grouping" do
      fields = mods_display_note(@complex_label).fields
      fields.length.should == 3
      fields.first.label.should == "Note"
      fields.first.values.length == 2
      fields.first.values.should == ["Note Field", "2nd Note Field"]
      
      fields[1].label == "Statement of responsibility"
      fields[1].values.length == 1
      fields[1].values.should == ["SoR"]
      
      fields.last.label.should == "Note"
      fields.last.values.length == 1
      fields.last.values.should == ["Another Note"]
    end
  end
  
end