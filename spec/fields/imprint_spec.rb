require 'spec_helper'
require 'fixtures/imprint_fixtures'

include ImprintFixtures

def mods_display_imprint(mods_text)
  # create a new MODS from provided string and generate an Imprint field
  ModsDisplay::Imprint.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  )
end

describe ModsDisplay::Imprint do
  describe 'labels' do
    it 'should get the Imprint label by default' do
      expect(mods_display_imprint(imprint_mods).fields.first.label).to eq('Imprint:')
    end
    it 'should get the label from non-imprint origin info fields' do
      fields = mods_display_imprint(edition_and_date_mods).fields
      expect(fields.first.label).to eq('Date valid:')
      expect(fields.last.label).to eq('Issuance:')
    end
    it 'should get multiple labels when we have mixed content' do
      expect(mods_display_imprint(mixed_mods).fields.map(&:label)).to eq(['Imprint:', 'Date captured:', 'Issuance:'])
    end
    it 'should use the displayLabel when available' do
      expect(mods_display_imprint(display_label).fields.map(&:label)).to eq(['TheLabel:', 'IssuanceLabel:'])
    end
  end

  describe 'fields' do
    it 'should return various parts of the imprint' do
      expect(mods_display_imprint(imprint_mods).fields.map(&:values).join(' ')).to eq(
        'An edition - A Place : A Publisher, An Issue Date, Another Date'
      )
    end
    it 'should handle the punctuation when the edition is missing' do
      values = mods_display_imprint(no_edition_mods).fields.map(&:values).join(' ')
      expect(values.strip).not_to match(/^-/)
      expect(values).to match(/^A Place/)
    end
    it 'should get the text for non-imprint origin info fields' do
      fields = mods_display_imprint(edition_and_date_mods).fields
      expect(fields.first.values).to eq(['A Valid Date'])
      expect(fields.last.values).to eq(['The Issuance'])
    end
    it 'should handle mixed mods properly' do
      values = mods_display_imprint(mixed_mods).fields
      expect(values.length).to eq(3)
      expect(values.map(&:values)).to include(['A Place : A Publisher'])
      expect(values.map(&:values)).to include(['The Issuance'])
      expect(values.map(&:values)).to include(['The Capture Date'])
    end
  end
  describe 'date processing' do
    describe 'ranges' do
      it "should join start and end point ranges with a '-'" do
        fields = mods_display_imprint(date_range).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['1820-1825'])
      end
      it 'should handle open ranges properly' do
        fields = mods_display_imprint(open_date_range).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['1820-'])
      end
      it 'should handle when there are more than 3 of the same date w/i a range' do
        fields = mods_display_imprint(three_imprint_dates).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820-1825?]'])
      end
      it 'should apply the qualifier decoration in the imprints' do
        fields = mods_display_imprint(qualified_imprint_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820?]'])
      end
      it 'should handle date ranges in imprints' do
        fields = mods_display_imprint(imprint_date_range).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['1820-1825'])
      end
      it 'should handle encoded dates properly' do
        fields = mods_display_imprint(encoded_date_range).fields
        expect(fields.length).to eq 1
        expect(fields.first.values).to eq ['February 01, 2008-December 02, 2009']
      end

      it 'should handle B.C. and A.D. dates appropriately' do
        fields = mods_display_imprint(bc_ad_imprint_date_fixture).fields
        expect(fields.length).to eq 1
        expect(fields.first.values).to eq ['14 B.C.-44 A.D.']
      end

      it 'should transform year zero dates to 1 A.D.' do
        year_zero_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>0</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(year_zero_date).fields
        expect(fields.first.values).to eq ['1 A.D.']
      end
    end
    describe 'duplication' do
      it 'should only return the qualified date when present' do
        fields = mods_display_imprint(dup_qualified_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820?]'])
      end
      it 'should use the non-encoded date when prsent' do
        fields = mods_display_imprint(dup_unencoded_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[ca. 1820]'])
      end
      it 'should handle copyright dates correctly' do
        fields = mods_display_imprint(dup_copyright_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['c1820'])
      end
      it 'should only return one when no attributes are present' do
        fields = mods_display_imprint(dup_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['1820'])
      end
    end
    describe 'qualifier decoration' do
      it "should prepend a 'c' to approximate dates" do
        fields = mods_display_imprint(approximate_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[ca. 1820]'])
      end
      it "should append a '?' to a questionable dates and wrap them in square-brackets" do
        fields = mods_display_imprint(questionable_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820?]'])
      end
      it 'should wrap inferred dates in square-brackets' do
        fields = mods_display_imprint(inferred_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820]'])
      end
    end
    describe 'encoded dates' do
      describe 'W3CDTF' do
        it 'should handle single year dates properly' do
          fields = mods_display_imprint(encoded_dates).fields
          expect(fields.length).to eq(4)
          expect(fields.find do |field|
            field.label == 'Imprint:'
          end.values).to eq(['2013'])
        end
        it 'should handle month+year dates properly' do
          fields = mods_display_imprint(encoded_dates).fields
          expect(fields.length).to eq(4)
          expect(fields.find do |field|
            field.label == 'Date captured:'
          end.values).to eq(['July 2013'])
        end
        it 'should handle full dates properly' do
          fields = mods_display_imprint(encoded_dates).fields
          expect(fields.length).to eq(4)
          expect(fields.find do |field|
            field.label == 'Date created:'
          end.values).to eq(['July 10, 2013'])
        end
        it "should not try to handle dates we can't parse" do
          fields = mods_display_imprint(encoded_dates).fields
          expect(fields.length).to eq(4)
          expect(fields.find do |field|
            field.label == 'Date modified:'
          end.values).to eq(['Jul. 22, 2013'])
        end
      end

      describe 'iso8601' do
        it 'handles full dates properly' do
          fields = mods_display_imprint(iso8601_encoded_dates).fields
          expect(fields.length).to eq(2)
          expect(fields.find do |field|
            field.label == 'Date created:'
          end.values).to eq(['November 14, 2013'])
        end
        it "should not try to handle dates we can't parse" do
          fields = mods_display_imprint(iso8601_encoded_dates).fields
          expect(fields.length).to eq(2)
          expect(fields.find do |field|
            field.label == 'Date modified:'
          end.values).to eq(['Jul. 22, 2013'])
        end
      end
    end
    describe 'bad dates' do
      it 'should ignore date values' do
        fields = mods_display_imprint(bad_dates).fields
        expect(fields.length).to eq(2)
        fields.each do |field|
          expect(field.values.join).not_to include '9999'
        end
      end
      it 'should handle invalid dates by returning the original value' do
        fields = mods_display_imprint(invalid_dates).fields
        expect(fields.length).to eq(2)
        expect(fields.last.values).to eq(['1920-09-00'])
      end

      it 'should not append A.D. to empty dates' do
        empty_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated/>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(empty_date).fields
        expect(fields.first.values).to eq ['']
      end

      it 'should not append A.D. to dates consisting of 2+ zeroes' do
        zeroes_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>0000</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(zeroes_date).fields
        expect(fields.first.values).to eq ['0000']
      end

      it 'should not append A.D. to dates that are not integers' do
        non_integer_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>19xx</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(non_integer_date).fields
        expect(fields.first.values).to eq ['19xx']
      end
    end
  end

  describe 'punctuation' do
    it 'should not duplicate punctuation' do
      fields = mods_display_imprint(punctuation_imprint_fixture).fields
      expect(fields.length).to eq 1
      expect(fields.first.values).to eq ['San Francisco : Chronicle Books, 2015.']
    end
  end

  describe 'place processing' do
    it 'should exclude encoded places' do
      fields = mods_display_imprint(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['[Amsterdam]', '[United States]', 'Netherlands'])
    end
    it "should translate encoded place if there isn't a text (or non-typed) value available" do
      fields = mods_display_imprint(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to include 'Netherlands'
    end
    it "should ignore 'xx' country codes" do
      fields = mods_display_imprint(xx_country_code).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['1994'])
    end
  end
  describe 'to_html' do
    it 'should have individual dt/dd pairs for mixed content' do
      html = mods_display_imprint(mixed_mods).to_html
      expect(html.scan(%r{<dt>Imprint</dt>}).length).to eq(1)
      expect(html.scan(%r{<dt>Issuance</dt>}).length).to eq(1)
      expect(html.scan(%r{<dt>Date captured</dt>}).length).to eq(1)
      expect(html.scan(/<dd>/).length).to eq(3)
    end
  end
end
