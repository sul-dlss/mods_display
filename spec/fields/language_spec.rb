require "spec_helper"
require "mods_display/configuration"
require "mods_display/configuration/base"
require "mods_display/fields/field"
require "mods_display/fields/language"
require "stanford-mods"

def mods_display_language(mods_record)
  ModsDisplay::Language.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Language do
  before(:all) do
    @language = Stanford::Mods::Record.new.from_str("<mods><language><languageTerm>eng</languageTerm></language></mods>", false).language.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><language displayLabel='Lang'>eng</language></mods>", false).language.first
    @no_lang = Stanford::Mods::Record.new.from_str("<mods><language displayLabel='Lang'>zzzxxx</language></mods>", false).language.first
    @display_form = Stanford::Mods::Record.new.from_str("<mods><language><languageTerm>zzzxxx</languageTerm><displayForm>Klingon</displayForm></language></mods>", false).language.first
  end
  describe "label" do
    it "should default to Language when no displayLabel is available" do
      mods_display_language(@language).label.should == "Language"
    end
    it "should use the displayLabel attribute when present" do
      mods_display_language(@display_label).label.should == "Lang"
    end
  end
  
  describe "values" do
    it "should return the language code translation" do
      mods_display_language(@language).text.should == "English"
    end
    it "should return the code if the languages table does not have a translation" do
      mods_display_language(@no_lang).text.should == "zzzxxx"
    end
    it "should return a displayForm if there is one" do
      mods_display_language(@display_form).text.should == "Klingon"
    end
  end
  
end