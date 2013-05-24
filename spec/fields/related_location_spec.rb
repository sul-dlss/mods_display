require "spec_helper"

def mods_display_related_location(mods_record)
  ModsDisplay::RelatedLocation.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::RelatedLocation do
  before(:all) do
    @location = Stanford::Mods::Record.new.from_str("<mods><relatedItem><location>The Location</location></relatedItem></mods>", false).related_item
    @non_location = Stanford::Mods::Record.new.from_str("<mods><relatedItem><title>No Location</title></relatedItem></mods>", false).related_item
    @display_label = Stanford::Mods::Record.new.from_str("<mods><relatedItem displayLabel='Special Location'><location>The Location</location></relatedItem></mods>", false).related_item
  end
  describe "label" do
    it "should default to Location" do
      mods_display_related_location(@location).fields.first.label.should == "Location"
    end
    it "should get the displayLabel if available" do
      mods_display_related_location(@display_label).label.should == "Special Location"
    end
  end
  describe "fields" do
    it "should get a location if it is available" do
      fields = mods_display_related_location(@location).fields
      fields.length.should == 1
      fields.first.values.should == ["The Location"]
    end
    it "should not return any fields if there is no location" do
      mods_display_related_location(@non_location).fields.should == []
    end
  end
end