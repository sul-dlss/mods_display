require "spec_helper"

def mods_display_title(mods_record)
  ModsDisplay::Title.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Title do
  before(:all) do
    @title = Stanford::Mods::Record.new.from_str("<mods><titleInfo><title>Title</title></titleInfo></mods>", false).title_info
    @title_parts = Stanford::Mods::Record.new.from_str("<mods><titleInfo><nonSort>The</nonSort><title>Title</title><subTitle>For</subTitle><partName>Something</partName><partNumber>62</partNumber></titleInfo></mods>", false).title_info
    @display_label = Stanford::Mods::Record.new.from_str("<mods><titleInfo displayLabel='MyTitle'><title>Title</title></titleInfo></mods>", false).title_info
    @display_form = Stanford::Mods::Record.new.from_str("<mods><titleInfo><title>Title</title><displayForm>The Title of This Item</displayForm></titleInfo></mods>", false).title_info
    @alt_title = Stanford::Mods::Record.new.from_str("<mods><titleInfo type='alternative'><title>Title</title></titleInfo></mods>", false).title_info
  end
  describe "labels" do
    it "should return a default label of Title if nothing else is available" do
      mods_display_title(@title).fields.first.label.should == "Title"
    end
    it "should return an appropriate label from the type attribute" do
      mods_display_title(@alt_title).fields.first.label.should == "Alternative Title"
    end
    it "should return the label held in the displayLabel attribute of the titleInfo element when available" do
      mods_display_title(@display_label).fields.first.label.should == "MyTitle"
    end
  end
  describe "fields" do
    it "should return an array of label/value objects" do
      values = mods_display_title(@display_label).fields
      values.length.should == 1
      values.first.should be_a ModsDisplay::Values
      values.first.label.should == "MyTitle"
      values.first.values.should == ["Title"]
    end
  end
  describe "text" do
    it "should construct all the elements in titleInfo" do
      mods_display_title(@title_parts).fields.first.values.should include "The Title : For. Something, 62"
    end
    it "should use the displayForm when available" do
      mods_display_title(@display_form).fields.first.values.should include "The Title of This Item"
    end
    it "should return the basic text held in a sub element of titleInfo" do
      mods_display_title(@title).fields.first.values.should include "Title"
    end
  end
  
end