require "spec_helper"

def mods_display_description(mods)
  ModsDisplay::Description.new(mods, ModsDisplay::Configuration::Base.new, double("controller"))
end

describe ModsDisplay::Description do
  before(:all) do
    @form = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><note>Description Note</note></physicalDescription></mods>", false).physical_description
    @display_label = Stanford::Mods::Record.new.from_str("<mods><physicalDescription displayLabel='SpecialLabel'><note>Description Note</note></physicalDescription></mods>", false).physical_description
    @child_display_label = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><note displayLabel='Note Label'>Description Note</note></physicalDescription></mods>", false).physical_description
    @mixed = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><note>Description Note</note><digitalOrigin>Digital Origin Note</digitalOrigin></physicalDescription></mods>", false).physical_description
  end
  describe "labels" do
    it "should use the displayLabel if one is provided" do
      mods_display_description(@display_label).fields.first.label.should == "SpecialLabel"
    end
    it "should get the default label for a child element" do
      mods_display_description(@form).fields.first.label.should == "Note"
    end
    it "should get multiple lables for mixed content" do
      mods_display_description(@mixed).fields.map{|v| v.label }.should == ["Note", "Digital origin"]
    end
    it "should get the display label from child elements" do
      mods_display_description(@child_display_label).fields.map{|f| f.label }.should == ["Note Label"]
    end
  end
  
  describe "fields" do
    it "should get the value from a field in physicalDescription" do
      mods_display_description(@form).fields.first.values.should == ["Description Note"]
    end
    it "should get multiple values for mixed content" do
      mods_display_description(@mixed).fields.map{|v| v.values }.should == [["Description Note"], ["Digital Origin Note"]]
    end
  end
end