require "spec_helper"
def mods_display_format(mods)
  ModsDisplay::Format.new(mods, ModsDisplay::Configuration::Base.new, double("controller"))
end

describe ModsDisplay::Format do
  before(:all) do
    @format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Format</typeOfResource></mods>", false).typeOfResource
    @duplicate_forms = Stanford::Mods::Record.new.from_str("<mods><physicalDescription><form>Map</form><form>Map</form></physicalDescription></mods>", false)
    @display_label = Stanford::Mods::Record.new.from_str("<mods><typeOfResource displayLabel='SpecialFormat'>Mixed Materials</typeOfResource></mods>", false).typeOfResource
    @space_format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Mixed Materials</typeOfResource></mods>", false).typeOfResource
    @slash_format = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Manuscript/Archive</typeOfResource></mods>", false).typeOfResource
  end
  describe "format_class" do
    it "should remove any spaces" do
      expect(ModsDisplay::Format.send(:format_class, "Mixed Materials")).to eq("mixed_materials")
    end
    it "should replace any slashes" do
      expect(ModsDisplay::Format.send(:format_class, "Manuscript/Archive")).to eq("manuscript_archive")
    end
  end
  describe "fields" do
    describe "form" do
      it "should remove duplicate values" do
        fields = mods_display_format(@duplicate_forms).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(["Map"])
      end
    end
  end
end