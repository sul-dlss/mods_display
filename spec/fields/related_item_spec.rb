require "spec_helper"

def mods_display_item(mods_record)
  ModsDisplay::RelatedItem.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::RelatedItem do
  before(:all) do
    @item = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo>A Related Item</titleInfo></relatedItem></mods>", false).related_item.first
    @linked_item = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo>A Related Item</titleInfo><location><url>http://library.stanford.edu/</url></location></relatedItem></mods>", false).related_item.first
    @collection = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo>This is a Collection</titleInfo><typeOfResource collection='yes' /></relatedItem></mods>", false).related_item.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><relatedItem displayLabel='Special Item'><titleInfo>A Related Item</titleInfo></relatedItem></mods>", false).related_item.first
  end
  describe "label" do
    it "should default to Related Item" do
      mods_display_item(@item).label.should == "Related Item"
    end
    it "should get the displayLabel if available" do
      mods_display_item(@display_label).label.should == "Special Item"
    end
  end
  describe "fields" do
    it "should get a location if it is available" do
      fields = mods_display_item(@item).fields
      fields.length.should == 1
      fields.first.values.should == ["A Related Item"]
    end
    it "should return a link if there is a location/url present" do
      fields = mods_display_item(@linked_item).fields
      fields.length.should == 1
      fields.first.values.should == ["<a href='http://library.stanford.edu/'>A Related Item</a>"]
    end
    it "should not return any fields if the described related item is a collection" do
      mods_display_item(@collection).fields.should == []
    end
  end
end