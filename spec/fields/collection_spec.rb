require "spec_helper"

def mods_display_collection(mods_record)
  ModsDisplay::Collection.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Collection do
  before(:all) do
    @collection = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo><title>The Collection</title></titleInfo><typeOfResource collection='yes' /></relatedItem></mods>", false).related_item.first
    @non_collection = Stanford::Mods::Record.new.from_str("<mods><relatedItem><titleInfo><title>Not a Collection</title></titleInfo></relatedItem></mods>", false).related_item.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><relatedItem displayLabel='Special Collection'><titleInfo><title>Not a Collection</title></titleInfo></relatedItem></mods>", false).related_item.first
  end
  describe "label" do
    it "should default to Collection" do
      mods_display_collection(@collection).label.should == "Collection"
    end
    it "should get the displayLabel if available" do
      mods_display_collection(@display_label).label.should == "Special Collection"
    end
  end
  describe "fields" do
    it "should get a collection title if there is an appropriate typeOfResource field with the collection attribute" do
      fields = mods_display_collection(@collection).fields
      fields.length.should == 1
      fields.first.values.should == ["The Collection"]
    end
    it "should not return anything if the there is not an appropriate typeOfResource field with the collection attribute" do
      mods_display_collection(@non_collection).fields.should == []
    end
  end
end