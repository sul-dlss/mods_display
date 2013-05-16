require "spec_helper"
require "mods_display/configuration"
require "mods_display/configuration/base"
require "mods_display/fields/field"
require "mods_display/fields/imprint"
require "stanford-mods"

def mods_display_imprint(mods_record)
  ModsDisplay::Imprint.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Imprint do
  before(:all) do
    imprint_mods = <<-MODS
      <mods>
        <originInfo>
          <place>A Place</place>
          <publisher>A Publisher</publisher>
          <dateCreated>A Create Date</dateCreated>
          <dateIssued>An Issue Date</dateIssued>
          <dateCaptured>A Capture Date</dateCaptured>
          <dateOther>Another Date</dateOther>
        </originInfo>
      </mods>
    MODS
    origin_info_mods = <<-MODS
      <mods>
        <originInfo>
          <dateValid>A Valid Date</dateValid>
        </originInfo>
        <originInfo>
          <edition>The Edition</edition>
        </originInfo>
      </mods>
    MODS
    encoded_date = <<-MODS
      <mods>
        <originInfo>
          <place>A Place</place>
          <dateIssued encoding="an-encoding">An Encoded Date</dateIssued>
        </originInfo>
      </mods>
    MODS
    mixed_mods = <<-MODS
      <mods>
        <originInfo>
          <place>A Place</place>
          <publisher>A Publisher</publisher>
          <edition>The Edition</edition>
        </originInfo>
      </mods>
    MODS
    display_form = <<-MODS
      <mods>
        <originInfo>
          <place>A Place</place>
          <publisher>A Publisher</publisher>
          <displayForm>The Display Form</displayForm>
        </originInfo>
        <originInfo displayLabel="TheLabel">
          <place>A Place</place>
          <publisher>A Publisher</publisher>
          <displayForm>The Display Form</displayForm>
        </originInfo>
      </mods>
    MODS
    
    @imprint = Stanford::Mods::Record.new.from_str(imprint_mods, false).origin_info.first
    @date_valid = Stanford::Mods::Record.new.from_str(origin_info_mods, false).origin_info.first
    @edition = Stanford::Mods::Record.new.from_str(origin_info_mods, false).origin_info.last
    @encoded_date = Stanford::Mods::Record.new.from_str(encoded_date, false).origin_info.first
    @mixed = Stanford::Mods::Record.new.from_str(mixed_mods, false).origin_info.first
    @display_form = Stanford::Mods::Record.new.from_str(display_form, false).origin_info.first
    @display_form_with_label = Stanford::Mods::Record.new.from_str(display_form, false).origin_info.last
  end

  describe "labels" do
    it "should get the Imprint label by default" do
      mods_display_imprint(@imprint).values.first[:label].should == "Imprint"
    end
    it "should get the label from non-imprint origin info fields" do
      mods_display_imprint(@date_valid).values.first[:label].should == "Date Valid"
      mods_display_imprint(@edition).values.first[:label].should == "Edition"
    end
    it "should get multiple labels when we have mixed content" do
      mods_display_imprint(@mixed).values.map{|val| val[:label] }.should == ["Imprint", "Edition"]
    end
  end

  describe "values" do
    it "should return various parts of the imprint" do
      mods_display_imprint(@imprint).values.map{|val| val[:value] }.join(" ").should == "A Place A Publisher A Create Date An Issue Date A Capture Date Another Date"
    end
    it "should get the text for non-imprint origin info fields" do
      mods_display_imprint(@date_valid).values.first[:value].should == "A Valid Date"
      mods_display_imprint(@edition).values.first[:value].should == "The Edition"
    end
    it "should omit dates with an encoding attribute" do
      mods_display_imprint(@encoded_date).values.map{|val| val[:value] }.join.should_not include("An Encoded Date")
    end
    it "should handle mixed mods properly" do
      values = mods_display_imprint(@mixed).values
      values.length.should == 2
      values.map{|val| val[:value]}.should include("A Place A Publisher")
      values.map{|val| val[:value]}.should include("The Edition")
    end
  end
  describe "to_html" do
    it "should return the display form if one is available" do
      html = mods_display_imprint(@display_form).to_html
      html.scan(/<dd>/).length.should == 1
      html.should match(/<dd>The Display Form<\/dd>/)
    end
    it "should return the displayLabel when present if we're using the displayForm" do
      mods_display_imprint(@display_form_with_label).to_html.should match(/<dt>TheLabel:<\/dt>/)
    end
    it "should have individual dt/dd pairs for mixed content" do
      html = mods_display_imprint(@mixed).to_html
      html.scan(/<dt>Imprint:<\/dt>/).length.should == 1
      html.scan(/<dt>Edition:<\/dt>/).length.should == 1
      html.scan(/<dd>/).length.should == 2
    end
  end

end