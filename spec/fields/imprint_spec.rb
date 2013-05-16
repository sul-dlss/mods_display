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
    @imprint = Stanford::Mods::Record.new.from_str(imprint_mods, false).origin_info.first
    @date_valid = Stanford::Mods::Record.new.from_str(origin_info_mods, false).origin_info.first
    @edition = Stanford::Mods::Record.new.from_str(origin_info_mods, false).origin_info.last
    @encoded_date = Stanford::Mods::Record.new.from_str(encoded_date, false).origin_info.first
    @mixed = Stanford::Mods::Record.new.from_str(mixed_mods, false).origin_info.first
  end

  describe "labels" do
    it "should get the Imprint label by default" do
      mods_display_imprint(@imprint).label.should == "Imprint"
    end
    it "should get the label from non-imprint origin info fields" do
      mods_display_imprint(@date_valid).label.should == "Date Valid"
      mods_display_imprint(@edition).label.should == "Edition"
    end
  end

  describe "values" do
    it "should return various parts of the imprint" do
      mods_display_imprint(@imprint).text.should == "A Place A Publisher A Create Date An Issue Date A Capture Date Another Date"
    end
    it "should get the text for non-imprint origin info fields" do
      mods_display_imprint(@date_valid).text.should == "A Valid Date"
      mods_display_imprint(@edition).text.should == "The Edition"
    end
    it "should omit dates with an encoding attribute" do
      mods_display_imprint(@encoded_date).text.should_not include("An Encoded Date")
    end
    it "should handle mixed mods properly" do
      pending
    end
  end
end