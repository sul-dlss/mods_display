require "spec_helper"

def mods_display_description(mods)
  ModsDisplay::Description.new(mods, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Description do
  before(:all) do
    @form = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><form>Form Note</form></physicalDescription></mods>", false).physical_description
    @display_label = Stanford::Mods::Record.new.from_str("<mods><physicalDescription displayLabel='SpecialLabel'><form>Form Note</form></physicalDescription></mods>", false).physical_description
    @child_display_label = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><form displayLabel='Form Label'>Form Note</form></physicalDescription></mods>", false).physical_description
    @mixed = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><form>Form Note</form><extent>Extent Note</extent></physicalDescription></mods>", false).physical_description
  end
  describe "labels" do
    it "should use the displayLabel if one is provided" do
      mods_display_description(@display_label).fields.first.label.should == "SpecialLabel"
    end
    it "should get the default label for a child element" do
      mods_display_description(@form).fields.first.label.should == "Form"
    end
    it "should get multiple lables for mixed content" do
      mods_display_description(@mixed).fields.map{|v| v.label }.should == ["Form", "Extent"]
    end
    it "should get the display label from child elements" do
      mods_display_description(@child_display_label).fields.map{|f| f.label }.should == ["Form Label"]
    end
  end
  
  describe "fields" do
    it "should get the value from a field in physicalDescription" do
      mods_display_description(@form).fields.first.values.should == ["Form Note"]
    end
    it "should get multiple values for mixed content" do
      mods_display_description(@mixed).fields.map{|v| v.values }.should == [["Form Note"], ["Extent Note"]]
    end
  end
end