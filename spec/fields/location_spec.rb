require "spec_helper"

def mods_display_location(mods_record)
  ModsDisplay::Location.new(mods_record, ModsDisplay::Configuration::Base.new, double("controller"))
end

describe ModsDisplay::Note do
  before(:all) do
    @location = Stanford::Mods::Record.new.from_str("<mods><location><physicalLocation>The Location</physicalLocation></location></mods>", false).location
    @urls = Stanford::Mods::Record.new.from_str("<mods><location><url displayLabel='Stanford University Library'>http://library.stanford.edu</url></location><location displayLabel='PURL'><url>http://purl.stanford.edu</url></location></mods>", false).location
    @display_label = Stanford::Mods::Record.new.from_str("<mods><location displayLabel='Special Label'><shelfLocation>On Shelf A</shelfLocation></location></mods>", false).location
    @repository_label = Stanford::Mods::Record.new.from_str("<mods><location><physicalLocation type='repository'>Location Field</physicalLocation></location></mods>", false).location
  end
  describe "label" do
    it "should have a default label" do
      mods_display_location(@location).fields.first.label.should == "Location"
    end
    it "should use the displayLabel attribute when one is available" do
      mods_display_location(@display_label).fields.first.label.should == "Special Label"
    end
    it "should handle the URL labels correctly" do
      mods_display_location(@urls).fields.map{|f| f.label}.should == ["Location", "PURL"]
    end
    it "should use get a label from a list of translations" do
      mods_display_location(@repository_label).fields.first.label.should == "Repository"
    end
  end  
  describe "fields" do
    describe "URLs" do
      it "should link and use the displayLabel as text" do
        fields = mods_display_location(@urls).fields
        fields.length.should == 2
        field = fields.find{|f| f.label == "Location"}
        field.values.should == ["<a href='http://library.stanford.edu'>Stanford University Library</a>"]
      end
      it "should link the URL itself in the absence of a displayLabel on the url element" do
        fields = mods_display_location(@urls).fields
        fields.length.should == 2
        field = fields.find{|f| f.label == "PURL"}
        field.values.should == ["<a href='http://purl.stanford.edu'>http://purl.stanford.edu</a>"]
      end
    end
  end
end