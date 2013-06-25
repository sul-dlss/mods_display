require "spec_helper"

def mods_display_genre(mods_record)
  ModsDisplay::Genre.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Abstract do
  before(:all) do
    @genre = Stanford::Mods::Record.new.from_str("<mods><genre>Map Data</abstract></genre>", false).genre
    @display_label = Stanford::Mods::Record.new.from_str("<mods><genre displayLabel='Special label'>Catographic</genre></mods>", false).genre
  end
  describe "labels" do
    it "should return a default 'Genre' label" do
      fields = mods_display_genre(@genre).fields
      fields.length.should == 1
      fields.first.label.should == "Genre"
    end
    it "should use a display label when one is available" do
      fields = mods_display_genre(@display_label).fields
      fields.length.should == 1
      fields.first.label.should == "Special label"
    end
  end
end