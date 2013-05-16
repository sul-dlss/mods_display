require "spec_helper"

def mods_display_description(mods)
  ModsDisplay::Description.new(mods, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Description do
  before(:all) do
    @form = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><form>Form Note</form></physicalDescription></mods>", false).physical_description.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><physicalDescription displayLabel='SpecialLabel'><form>Form Note</form></physicalDescription></mods>", false).physical_description.first
    @mixed = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><form>Form Note</form><extent>Extent Note</extent></physicalDescription></mods>", false).physical_description.first
  end
  describe "labels" do
    it "should use the dislayLabel if one is provided" do
      mods_display_description(@display_label).values.first[:label].should == "SpecialLabel"
    end
    it "should get the default label for a child element" do
      mods_display_description(@form).values.first[:label].should == "Form"
    end
    it "should get multiple lables for mixed content" do
      mods_display_description(@mixed).values.map{|v| v[:label] }.should == ["Form", "Extent"]
    end
  end
  
  describe "values" do
    it "should get the value from a field in physicalDescription" do
      mods_display_description(@form).values.first[:value].should == "Form Note"
    end
    it "should get multiple values for mixed content" do
      mods_display_description(@mixed).values.map{|v| v[:value] }.should == ["Form Note", "Extent Note"]
    end
  end
end