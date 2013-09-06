require "spec_helper"

def mods_display_access_condition(mods_record)
  ModsDisplay::AccessCondition.new(mods_record, ModsDisplay::Configuration::AccessCondition.new, mock("controller"))
end
def mods_display_versioned_access_condition(mods_record, version)
  ModsDisplay::AccessCondition.new(mods_record, ModsDisplay::Configuration::AccessCondition.new{cc_license_version version}, mock("controller"))
end
def mods_display_non_ignore_access_condition(mods_record)
  ModsDisplay::AccessCondition.new(mods_record, ModsDisplay::Configuration::AccessCondition.new{display!}, mock("controller"))
end

describe ModsDisplay::AccessCondition do
  before :all do
    @access_condition = Stanford::Mods::Record.new.from_str("<mods><accessCondition>Access Condition Note</accessCondition></mods>", false).accessCondition
    @restrict_condition = Stanford::Mods::Record.new.from_str("<mods><accessCondition type='restrictionOnAccess'>Restrict Access Note1</accessCondition><accessCondition type='restriction on access'>Restrict Access Note2</accessCondition></mods>", false).accessCondition
    @copyright_note = Stanford::Mods::Record.new.from_str("<mods><accessCondition type='copyright'>This is a (c) copyright Note.  Single instances of (c) should also be replaced in these notes.</accessCondition></mods>", false).accessCondition
    @cc_license_note = Stanford::Mods::Record.new.from_str("<mods><accessCondition type='license'>CC by-sa: This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License</accessCondition></mods>", false).accessCondition
    @odc_license_note = Stanford::Mods::Record.new.from_str("<mods><accessCondition type='license'>ODC pddl: This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)</accessCondition></mods>", false).accessCondition
    @no_link_license_note = Stanford::Mods::Record.new.from_str("<mods><accessCondition type='license'>Unknown something: This work is licensed under an Unknown License and will not be linked</accessCondition></mods>", false).accessCondition
  end
  describe "labels" do
    it "should normalize types and assign proper labels" do
      fields = mods_display_access_condition(@restrict_condition).fields
      fields.length.should == 1
      fields.first.label.should == "Restriction on access"
      fields.first.values.each_with_index do |value, index|
        value.should match /^Restrict Access Note#{index+1}/
      end
    end
  end
  describe "fields" do
    describe "copyright" do
      it "should replace instances of '(c) copyright' with the HTML copyright entity" do
        fields = mods_display_access_condition(@copyright_note).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should == "This is a &copy; Note.  Single instances of &copy; should also be replaced in these notes."
      end
    end
    describe "licenses" do
      it "should add the appropriate classes to the html around the license" do
        fields = mods_display_access_condition(@no_link_license_note).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should match /^<div class='unknown-something'>.*<\/div>$/
      end
      it "should itentify and link CreativeCommons licenses properly" do
        fields = mods_display_access_condition(@cc_license_note).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should include("<a href='http://creativecommons.org/licenses/by-sa/3.0/'>This work is licensed under a Creative Commons Attribution-Noncommercial 3.0 Unported License</a>")
      end
      it "should itentify and link OpenDataCommons licenses properly" do
        fields = mods_display_access_condition(@odc_license_note).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should include("<a href='http://opendatacommons.org/licenses/pddl'>This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)</a>")
      end
      it "should have a configurable version for CC licenses" do
        fields = mods_display_versioned_access_condition(@cc_license_note, "4.0").fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should include("http://creativecommons.org/licenses/by-sa/4.0/")
        fields.first.values.first.should_not include("http://creativecommons.org/licenses/by-sa/3.0/")
      end
      it "should not apply configured version to NON-CC licenses" do
        fields = mods_display_versioned_access_condition(@odc_license_note, "4.0").fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should_not include("/4.0/")
      end
      it "should not attempt unknown license types" do
        fields = mods_display_access_condition(@no_link_license_note).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should     include("This work is licensed under an Unknown License and will not be linked")
        fields.first.values.first.should_not include("<a.*>")
      end
    end
  end
  describe "to_html" do
    it "should ignore access conditions by default" do
      mods_display_access_condition(@access_condition).to_html.should be_nil
    end
    it "should not ignore the access condition when ignore is set to false" do
      html = mods_display_non_ignore_access_condition(@access_condition).to_html
      html.should match /<dt.*>Access condition:<\/dt><dd>Access Condition Note<\/dd>/
    end
  end
end