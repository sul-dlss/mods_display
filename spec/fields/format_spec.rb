require "spec_helper"

def mods_display_format(mods)
  ModsDisplay::Format.new(mods, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Format do
  before(:all) do
    @format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Format</typeOfResource></mods>", false).typeOfResource.first
    @display_label = Stanford::Mods::Record.new.from_str("<mods><typeOfResource displayLabel='SpecialFormat'>Mixed Materials</typeOfResource></mods>", false).typeOfResource.first
    @space_format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Mixed Materials</typeOfResource></mods>", false).typeOfResource.first
    @slash_format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Manuscript/Archive</typeOfResource></mods>", false).typeOfResource.first
  end
  
  describe "labels" do
    it "should return the format label" do
      mods_display_format(@format).to_html.should match(/<dt>Format:<\/dt>/)
    end
    it "should return the displayLabel when available" do
      mods_display_format(@display_label).to_html.should match(/<dt>SpecialFormat:<\/dt>/)
    end
  end
  describe "format_class" do
    it "should remove any spaces" do
      mods_display_format(@space_format).send(:format_class).should == "mixed_materials"
    end
    it "should replace any slashes" do
      mods_display_format(@slash_format).send(:format_class).should == "manuscript_archive"
    end
  end

end