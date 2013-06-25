require "spec_helper"

def mods_display_item(mods_record)
  ModsDisplay::RelatedItem.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::RelatedItem do
  before(:all) do
    @item = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo>A Related Item</titleInfo></relatedItem></mods>", false).related_item
    @linked_item = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo>A Related Item</titleInfo><location><url>http://library.stanford.edu/</url></location></relatedItem></mods>", false).related_item
    @collection = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo>This is a Collection</titleInfo><typeOfResource collection='yes' /></relatedItem></mods>", false).related_item
    @display_label = Stanford::Mods::Record.new.from_str("<mods><relatedItem displayLabel='Special Item'><titleInfo>A Related Item</titleInfo></relatedItem></mods>", false).related_item
    @blank_item = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo><title></title></titleInfo><location><url></url></location></relatedItem></mods>", false).related_item
    @multi_items = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo><title>Library</title></titleInfo><location><url>http://library.stanford.edu</url></location></relatedItem><relatedItem><titleInfo><title>SDR</title></titleInfo><location><url>http://purl.stanford.edu</url></location></relatedItem></mods>", false).related_item
  end
  describe "label" do
    it "should default to Related Item" do
      mods_display_item(@item).fields.first.label.should == "Related item"
    end
    it "should get the displayLabel if available" do
      mods_display_item(@display_label).fields.first.label.should == "Special Item"
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
    it "should not return empty links when there is no title or link" do
      mods_display_item(@blank_item).fields.should == []
    end
    it "should collapse labels down into the same record" do
      fields = mods_display_item(@multi_items).fields
      fields.length.should == 1
      fields.first.label.should == "Related item"
      fields.first.values.length.should == 2
      fields.first.values.first.should =~ /<a href=.*>Library<\/a>/ or
      fields.first.values.last.should =~ /<a href=.*>SDR<\/a>/
    end
  end
end