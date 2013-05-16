require "spec_helper"

def mods_display_format(mods)
  ModsDisplay::Format.new(mods, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Format do
  before(:all) do
    @format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Format</typeOfResource></mods>").typeOfResource
    @display_label = Stanford::Mods::Record.new.from_str("<mods><typeOfResource displayLabel='SpecialFormat'>Mixed Materials</typeOfResource></mods>").typeOfResource
    @space_format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Mixed Materials</typeOfResource></mods>").typeOfResource
    @slash_format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Manuscript/Archive</typeOfResource></mods>").typeOfResource
    @reason = "Stanford::Mods::Record does not respond to #typeOfResource when XML present."
  end
  
  describe "labels" do
    it "should return the format label" do
      pending(@reason)
      mods_display_format(@format).to_html.should match(/<dt>Format<\/dt>/)
    end
    it "should return the displayLabel when available" do
      pending(@reason)
      mods_display_format(@display_label).to_html.should match(/<dt>SpecialFormat<\/dt>/)
    end
  end
  describe "format_class" do
    it "should remove any spaces" do
      pending(@reason)
      mods_display_format(@space_format).send(:format_class).should == "mixed_materials"
    end
    it "should replace any slashes" do
      pending(@reason)
      mods_display_format(@slash_format).send(:format_class).should == "manuscript_archive"
    end
  end

end