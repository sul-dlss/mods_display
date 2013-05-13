require "spec_helper"
require "mods_display/fields/title"
require "stanford-mods"

describe ModsDisplay::Title do
  before(:all) do
    @title = Stanford::Mods::Record.new.from_str("<mods><titleInfo><title>Title</title></titleInfo></mods>", false).title_info.first
    @title_parts = Stanford::Mods::Record.new.from_str("<mods><titleInfo><nonSort>The</nonSort><title>Title</title><subTitle>For</subTitle><partName>Something</partName><partNumber>62</partNumber></titleInfo></mods>", false).title_info.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><titleInfo displayLabel='MyTitle'><title>Title</title></titleInfo></mods>", false).title_info.first
    @display_form = Stanford::Mods::Record.new.from_str("<mods><titleInfo><title>Title</title><displayForm>The Title of This Item</displayForm></titleInfo></mods>", false).title_info.first
    @alt_title = Stanford::Mods::Record.new.from_str("<mods><titleInfo type='alternative'><title>Title</title></titleInfo></mods>", false).title_info.first
  end
  describe "labels" do
    it "should return a default label of Title if nothing else is available" do
      ModsDisplay::Title.new(@title).label.should == "Title"
    end
    it "should return an appropriate label from the type attribute" do
      ModsDisplay::Title.new(@alt_title).label.should == "Alternative Title"
    end
    it "should return the label held in the displayLabel attribute of the titleInfo element when available" do
      ModsDisplay::Title.new(@display_label).label.should == "MyTitle"
    end
  end
  describe "values" do
    it "should construct all the elements in titleInfo" do
      ModsDisplay::Title.new(@title_parts).text.should == "The Title For Something 62"
    end
    it "should use the displayForm when available" do
      pending
      ModsDisplay::Title.new(@display_form).text.should == "The Title of This Item"
    end
    it "should return the basic text held in a sub element of titleInfo" do
      ModsDisplay::Title.new(@title).text.should == "Title"
    end
  end
  
end