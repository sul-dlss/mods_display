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
    @imprint = Stanford::Mods::Record.new.from_str(imprint_mods, false).origin_info.first
  end
  
  describe "values" do
    it "should return various parts of the imprint" do
      mods_display_imprint(@imprint).text.should == "A Place A Publisher A Create Date An Issue Date A Capture Date Another Date"
    end
  end
end