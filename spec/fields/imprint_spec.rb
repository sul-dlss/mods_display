require "spec_helper"
require "fixtures/imprint_fixtures"

include ImprintFixtures

def mods_display_imprint(mods_record)
  ModsDisplay::Imprint.new(mods_record, ModsDisplay::Configuration::Imprint.new, mock("controller"))
end
def mods_display_format_date_imprint(mods_record)
  ModsDisplay::Imprint.new(mods_record, ModsDisplay::Configuration::Imprint.new{full_date_format "(%Y) %B, %d"; short_date_format "%B (%Y)"}, mock("controller"))
end

describe ModsDisplay::Imprint do
  before(:all) do
    @imprint = Stanford::Mods::Record.new.from_str(imprint_mods, false).origin_info
    @no_edition = Stanford::Mods::Record.new.from_str(no_edition_mods, false).origin_info
    @edition_and_date = Stanford::Mods::Record.new.from_str(origin_info_mods, false).origin_info
    @mixed = Stanford::Mods::Record.new.from_str(mixed_mods, false).origin_info
    @display_form = Stanford::Mods::Record.new.from_str(display_form, false).origin_info
    @display_form_with_label = Stanford::Mods::Record.new.from_str(display_form, false).origin_info
    @display_label = Stanford::Mods::Record.new.from_str(display_label, false).origin_info
    @date_range = Stanford::Mods::Record.new.from_str(date_range, false).origin_info
    @open_date_range = Stanford::Mods::Record.new.from_str(open_date_range, false).origin_info
    @dup_qualified_date = Stanford::Mods::Record.new.from_str(dup_qualified_date, false).origin_info
    @dup_unencoded_date = Stanford::Mods::Record.new.from_str(dup_unencoded_date, false).origin_info
    @dup_copyright_date = Stanford::Mods::Record.new.from_str(dup_copyright_date, false).origin_info
    @dup_date = Stanford::Mods::Record.new.from_str(dup_date, false).origin_info
    @approximate_date = Stanford::Mods::Record.new.from_str(approximate_date, false).origin_info
    @questionable_date = Stanford::Mods::Record.new.from_str(questionable_date, false).origin_info
    @inferred_date = Stanford::Mods::Record.new.from_str(inferred_date, false).origin_info
    @three_imprint_dates = Stanford::Mods::Record.new.from_str(three_imprint_dates, false).origin_info
    @qualified_imprint_date = Stanford::Mods::Record.new.from_str(qualified_imprint_date, false).origin_info
    @imprint_date_range = Stanford::Mods::Record.new.from_str(imprint_date_range, false).origin_info
    @encoded_place = Stanford::Mods::Record.new.from_str(encoded_place, false).origin_info
    @encoded_dates = Stanford::Mods::Record.new.from_str(encoded_dates, false).origin_info
    @bad_dates = Stanford::Mods::Record.new.from_str(bad_dates, false).origin_info
  end

  describe "labels" do
    it "should get the Imprint label by default" do
      mods_display_imprint(@imprint).fields.first.label.should == "Imprint"
    end
    it "should get the label from non-imprint origin info fields" do
      fields = mods_display_imprint(@edition_and_date).fields
      fields.first.label.should == "Date valid"
      fields.last.label.should == "Issuance"
    end
    it "should get multiple labels when we have mixed content" do
      mods_display_imprint(@mixed).fields.map{|val| val.label }.should == ["Imprint", "Date captured", "Issuance"]
    end
    it "should use the displayLabel when available" do
       mods_display_imprint(@display_label).fields.map{|val| val.label }.should == ["TheLabel", "IssuanceLabel"]
    end
  end

  describe "fields" do
    it "should return various parts of the imprint" do
      mods_display_imprint(@imprint).fields.map{|val| val.values }.join(" ").should == "An edition - A Place : A Publisher, An Issue Date, Another Date"
    end
    it "should handle the punctuation when the edition is missing" do
      values = mods_display_imprint(@no_edition).fields.map{|val| val.values }.join(" ")
      values.strip.should_not match(/^-/)
      values.should match(/^A Place/)
    end
    it "should get the text for non-imprint origin info fields" do
      fields = mods_display_imprint(@edition_and_date).fields
      fields.first.values.should == ["A Valid Date"]
      fields.last.values.should == ["The Issuance"]
    end
    it "should handle mixed mods properly" do
      values = mods_display_imprint(@mixed).fields
      values.length.should == 3
      values.map{|val| val.values}.should include(["A Place : A Publisher"])
      values.map{|val| val.values}.should include(["The Issuance"])
      values.map{|val| val.values}.should include(["The Capture Date"])
    end
  end
  describe "date processing" do
    describe "ranges" do
      it "should join start and end point ranges with a '-'" do
        fields = mods_display_imprint(@date_range).fields
        fields.length.should == 1
        fields.first.values.should == ["1820-1825"]
      end
      it "should handle open ranges properly" do
        fields = mods_display_imprint(@open_date_range).fields
        fields.length.should == 1
        fields.first.values.should == ["1820-"]
      end
      it "should handle when there are more than 3 of the same date w/i a range" do
        fields = mods_display_imprint(@three_imprint_dates).fields
        fields.length.should == 1
        fields.first.values.should == ["[1820-1825?]"]
      end
      it "should apply the qualifier decoration in the imprints" do
        fields = mods_display_imprint(@qualified_imprint_date).fields
        fields.length.should == 1
        fields.first.values.should == ["[1820?]"]
      end
      it "should handle date ranges in imprints" do
        fields = mods_display_imprint(@imprint_date_range).fields
        fields.length.should == 1
        fields.first.values.should == ["1820-1825"]
      end
    end
    describe "duplication" do
      it "should only return the qualified date when present" do
        fields = mods_display_imprint(@dup_qualified_date).fields
        fields.length.should == 1
        fields.first.values.should == ["[1820?]"]
      end
      it "should use the non-encoded date when prsent" do
        fields = mods_display_imprint(@dup_unencoded_date).fields
        fields.length.should == 1
        fields.first.values.should == ["[ca. 1820]"]
      end
      it "should handle copyright dates correctly" do
        fields = mods_display_imprint(@dup_copyright_date).fields
        fields.length.should == 1
        fields.first.values.should == ["c1820"]
      end
      it "should only return one when no attributes are present" do
        fields = mods_display_imprint(@dup_date).fields
        fields.length.should == 1
        fields.first.values.should == ["1820"]
      end
    end
    describe "qualifier decoration" do
      it "should prepend a 'c' to approximate dates" do
        fields = mods_display_imprint(@approximate_date).fields
        fields.length.should == 1
        fields.first.values.should == ["[ca. 1820]"]
      end
      it "should append a '?' to a questionable dates and wrap them in square-brackets" do
        fields = mods_display_imprint(@questionable_date).fields
        fields.length.should == 1
        fields.first.values.should == ["[1820?]"]
      end
      it "should wrap inferred dates in square-brackets" do
        fields = mods_display_imprint(@inferred_date).fields
        fields.length.should == 1
        fields.first.values.should == ["[1820]"]
      end
    end
    describe "encoded dates" do
      describe "W3CDTF" do
        it "should handle single year dates properly" do
          fields = mods_display_imprint(@encoded_dates).fields
          fields.length.should == 4
          fields.find do |field|
            field.label == "Imprint"
          end.values.should == ["2013"]
        end
        it "should handle month+year dates properly" do
          fields = mods_display_imprint(@encoded_dates).fields
          fields.length.should == 4
          fields.find do |field|
            field.label == "Date captured"
          end.values.should == ["July 2013"]
        end
        it "should handle full dates properly" do
          fields = mods_display_imprint(@encoded_dates).fields
          fields.length.should == 4
          fields.find do |field|
            field.label == "Date created"
          end.values.should == ["July 10, 2013"]
        end
        it "should not try to handle dates we can't parse" do
          fields = mods_display_imprint(@encoded_dates).fields
          fields.length.should == 4
          fields.find do |field|
            field.label == "Date modified"
          end.values.should == ["Jul. 22, 2013"]
        end
        it "should accept date configurations" do
          fields = mods_display_format_date_imprint(@encoded_dates).fields
          fields.length.should == 4
          fields.find do |field|
            field.label == "Date created"
          end.values.should == ["(2013) July, 10"]
          fields.find do |field|
            field.label == "Date captured"
          end.values.should == ["July (2013)"]
        end
      end
    end
    describe "bad dates" do
      it "should ignore date values" do
        fields = mods_display_imprint(@bad_dates).fields
        fields.length.should == 2
        fields.each do |field|
          field.values.join.should_not include "9999"
        end
      end
    end
  end
  describe "place processing" do
    it "should exclude encoded places" do
      fields = mods_display_imprint(@encoded_place).fields
      fields.length.should == 1
      fields.first.values.should == ["[Amsterdam]", "[United States]"]
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
      html.scan(/<dt title='Issuance'>Issuance:<\/dt>/).length.should == 1
      html.scan(/<dt title='Date captured'>Date captured:<\/dt>/).length.should == 1
      html.scan(/<dd>/).length.should == 3
    end
  end

end