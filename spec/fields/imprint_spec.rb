require "spec_helper"
require "fixtures/imprint_fixtures"

include ImprintFixtures

def mods_display_imprint(mods_record)
  ModsDisplay::Imprint.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Imprint do
  before(:all) do
    @imprint = Stanford::Mods::Record.new.from_str(imprint_mods, false).origin_info
    @edition_and_date = Stanford::Mods::Record.new.from_str(origin_info_mods, false).origin_info
    @encoded_date = Stanford::Mods::Record.new.from_str(encoded_date, false).origin_info
    @encoded_only = Stanford::Mods::Record.new.from_str(only_encoded_data, false).origin_info
    @mixed = Stanford::Mods::Record.new.from_str(mixed_mods, false).origin_info
    @display_form = Stanford::Mods::Record.new.from_str(display_form, false).origin_info
    @display_form_with_label = Stanford::Mods::Record.new.from_str(display_form, false).origin_info
    @display_label = Stanford::Mods::Record.new.from_str(display_label, false).origin_info
  end

  describe "labels" do
    it "should get the Imprint label by default" do
      mods_display_imprint(@imprint).fields.first.label.should == "Imprint"
    end
    it "should get the label from non-imprint origin info fields" do
      fields = mods_display_imprint(@edition_and_date).fields
      fields.first.label.should == "Date valid"
      fields.last.label.should == "Edition"
    end
    it "should get multiple labels when we have mixed content" do
      mods_display_imprint(@mixed).fields.map{|val| val.label }.should == ["Imprint", "Edition"]
    end
    it "should use the displayLabel when available" do
       mods_display_imprint(@display_label).fields.map{|val| val.label }.should == ["TheLabel", "EditionLabel", "EditionLabel"]
    end
  end

  describe "fields" do
    it "should return various parts of the imprint" do
      mods_display_imprint(@imprint).fields.map{|val| val.values }.join(" ").should == "A Place : A Publisher, A Create Date, An Issue Date, A Capture Date, Another Date"
    end
    it "should get the text for non-imprint origin info fields" do
      fields = mods_display_imprint(@edition_and_date).fields
      fields.first.values.should == ["A Valid Date"]
      fields.last.values.should == ["The Edition"]
    end
    it "should omit dates with an encoding attribute" do
      mods_display_imprint(@encoded_date).fields.map{|val| val.values }.join.should_not include("An Encoded Date")
    end
    it "should not try to return data w/ only encoded data" do
      mods_display_imprint(@encoded_only).fields.should be_empty
    end
    it "should handle mixed mods properly" do
      values = mods_display_imprint(@mixed).fields
      values.length.should == 2
      values.map{|val| val.values}.should include(["A Place : A Publisher"])
      values.map{|val| val.values}.should include(["The Edition"])
    end
  end
  describe "to_html" do
    it "should return the display form if one is available" do
      html = mods_display_imprint(@display_form).to_html
      html.scan(/<dd>/).length.should == 2
      html.scan(/<dd>The Display Form<\/dd>/).length.should == 2
    end
    it "should return the displayLabel when present if we're using the displayForm" do
      mods_display_imprint(@display_form_with_label).to_html.should match(/<dt title='TheLabel'>TheLabel:<\/dt>/)
    end
    it "should have individual dt/dd pairs for mixed content" do
      html = mods_display_imprint(@mixed).to_html
      html.scan(/<dt title='Imprint'>Imprint:<\/dt>/).length.should == 1
      html.scan(/<dt title='Edition'>Edition:<\/dt>/).length.should == 1
      html.scan(/<dd>/).length.should == 2
    end
  end

end