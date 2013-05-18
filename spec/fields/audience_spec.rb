require "spec_helper"

def mods_display_audience(mods_record)
  ModsDisplay::Audience.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Contents do
  before(:all) do
    @audience = Stanford::Mods::Record.new.from_str("<mods><targetAudience>Audience Note</targetAudience></mods>", false).targetAudience.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><targetAudience displayLabel='Special Label'>Audience Note</tableOfContents></mods>", false).targetAudience.first
  end
  describe "label" do
    it "should have a default label" do
      mods_display_audience(@contents).label.should == "Target audience"
    end
    it "should use the displayLabel attribute when one is available" do
      mods_display_audience(@display_label).label.should == "Special Label"
    end
  end  
  
end