# frozen_string_literal: true

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
    it 'gets the Imprint label by default' do
      expect(mods_display_imprint(imprint_mods).fields.first.label).to eq('Imprint:')
    end

    it 'gets the label from non-imprint origin info fields' do
      fields = mods_display_imprint(edition_and_date_mods).fields
      expect(fields.first.label).to eq('Date valid:')
      expect(fields.last.label).to eq('Issuance:')
    end

    it 'gets multiple labels when we have mixed content' do
      expect(mods_display_imprint(mixed_mods).fields.map(&:label)).to eq(['Imprint:', 'Date captured:', 'Issuance:'])
    end

    it 'uses the displayLabel when available' do
      expect(mods_display_imprint(display_label).fields.map(&:label)).to eq(['TheLabel:', 'IssuanceLabel:'])
    end
  end

  describe 'fields' do
    it 'returns various parts of the imprint' do
      expect(mods_display_imprint(imprint_mods).fields.map(&:values).join(' ')).to eq(
        'An edition - A Place : A Publisher, An Issue Date, Another Date'
      )
    end

    it 'handles the punctuation when the edition is missing' do
      values = mods_display_imprint(no_edition_mods).fields.map(&:values).join(' ')
      expect(values.strip).not_to match(/^-/)
      expect(values).to match(/^A Place/)
    end

    it 'gets the text for non-imprint origin info fields' do
      fields = mods_display_imprint(edition_and_date_mods).fields
      expect(fields.first.values).to eq(['A Valid Date'])
      expect(fields.last.values).to eq(['The Issuance'])
    end

    it 'handles mixed mods properly' do
      values = mods_display_imprint(mixed_mods).fields
      expect(values.length).to eq(3)
      expect(values.map(&:values)).to include(['A Place : A Publisher'])
      expect(values.map(&:values)).to include(['The Issuance'])
      expect(values.map(&:values)).to include(['The Capture Date'])
    end
  end

  describe 'date processing' do
    describe 'ranges' do
      it "joins start and end point ranges with a '-'" do
        date_range = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated point="end">1825</dateCreated>
              <dateCreated point="start">1820</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(date_range).fields
        expect(fields.first.values).to eq(['1820-1825'])
      end

      it 'handles open ranges properly' do
        open_date_range = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated point="start">1820</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(open_date_range).fields
        expect(fields.first.values).to eq(['1820-'])
      end

      it 'handles when there are more than 3 of the same date w/i a range' do
        three_imprint_dates = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>[1820-1825]</dateIssued>
              <dateIssued point="start" qualifier="questionable">1820</dateIssued>
              <dateIssued point="end" qualifier="questionable">1825</dateIssued>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(three_imprint_dates).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820-1825?]'])
      end

      it 'applies the qualifier decoration in the imprints' do
        fields = mods_display_imprint(qualified_imprint_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820?]'])
      end

      it 'applies the qualifier decoration separately to each date' do
        separate_qualifier_range = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated point="start" qualifier="approximate">1880</dateCreated>
              <dateCreated point="end">1906</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(separate_qualifier_range).fields
        expect(fields.first.values).to eq ['[ca. 1880]-1906']
      end

      it 'handles date ranges in imprints' do
        imprint_date_range = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateIssued>[1820]</dateIssued>
              <dateIssued point="start">1820</dateIssued>
              <dateIssued point="end">1825</dateIssued>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(imprint_date_range).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['1820-1825'])
      end

      it 'handles encoded dates properly' do
        fields = mods_display_imprint(encoded_date_range).fields
        expect(fields.length).to eq 1
        expect(fields.first.values).to eq ['February  1, 2008-December  2, 2009']
      end

      it 'handles BCE and CE dates appropriately' do
        fields = mods_display_imprint(bc_ad_imprint_date_fixture).fields
        expect(fields.length).to eq 1
        expect(fields.first.values).to eq ['14 BCE-44 CE']
      end
    end

    describe 'duplication' do
      it 'onlies return the qualified date when present' do
        fields = mods_display_imprint(dup_qualified_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820?]'])
      end

      it 'uses the non-encoded date when present' do
        dup_unencoded_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated encoding="marc">1820</dateCreated>
              <dateCreated>[ca. 1820]</dateCreated>
            </originInfo>
          </mods>
        MODS
        fields = mods_display_imprint(dup_unencoded_date).fields

        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[ca. 1820]'])
      end

      it 'handles copyright dates correctly' do
        fields = mods_display_imprint(dup_copyright_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['c1820'])
      end

      it 'onlies return one when no attributes are present' do
        fields = mods_display_imprint(dup_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['1820'])
      end
    end

    describe 'qualifier decoration' do
      it "prepends a 'ca.' to approximate dates" do
        fields = mods_display_imprint(approximate_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[ca. 1820]'])
      end

      it "appends a '?' to a questionable dates and wrap them in square-brackets" do
        fields = mods_display_imprint(questionable_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820?]'])
      end

      it 'wraps inferred dates in square-brackets' do
        fields = mods_display_imprint(inferred_date).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq(['[1820]'])
      end
    end

    describe 'encoded dates' do
      it 'transforms year zero dates to 1 BCE' do
        year_zero_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated encoding="edtf">0</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(year_zero_date).fields
        expect(fields.first.values).to eq ['1 BCE']
      end

      describe 'W3CDTF' do
        it 'handles single year dates properly' do
          single_year_date = <<-MODS
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateOther encoding="w3cDtF">2013</dateOther>
              </originInfo>
            </mods>
          MODS
          fields = mods_display_imprint(single_year_date).fields
          expect(fields.first.values).to eq ['2013']
        end

        it 'handles month+year dates properly' do
          month_year_date = <<-MODS
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateCaptured encoding="W3CDTF">2013-07</dateCaptured>
              </originInfo>
            </mods>
          MODS

          fields = mods_display_imprint(month_year_date).fields
          expect(fields.first.values).to eq ['July 2013']
        end

        it 'handles full precision dates properly' do
          full_precision_date = <<-MODS
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateCreated encoding="W3CdTf">2013-07-10</dateCreated>
              </originInfo>
            </mods>
          MODS

          fields = mods_display_imprint(full_precision_date).fields
          expect(fields.first.values).to eq ['July 10, 2013']
        end

        it "does not try to handle dates we can't parse" do
          unparseable_date = <<-MODS
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateModified encoding="w3cdtf">Jul. 22, 2013</dateModified>
              </originInfo>
            </mods>
          MODS

          fields = mods_display_imprint(unparseable_date).fields
          expect(fields.first.values).to eq ['Jul. 22, 2013']
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

        it "does not try to handle dates we can't parse" do
          fields = mods_display_imprint(iso8601_encoded_dates).fields
          expect(fields.length).to eq(2)
          expect(fields.find do |field|
            field.label == 'Date modified:'
          end.values).to eq(['Jul. 32, 2013'])
        end
      end
    end

    describe 'bad dates' do
      it 'ignores date values' do
        fields = mods_display_imprint(bad_dates).fields
        expect(fields.length).to eq(2)
        fields.each do |field|
          expect(field.values.join).not_to include '9999'
        end
      end

      it 'ignores blank date values' do
        empty_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated/>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(empty_date).fields
        expect(fields.first.values).to eq []
      end

      it 'handles invalid dates by returning the original value' do
        fields = mods_display_imprint(invalid_dates).fields
        expect(fields.length).to eq(2)
        expect(fields.last.values).to eq(['1920-09-32'])
      end

      it 'marks dates consisting solely of zeroes as 1 BCE' do
        zeroes_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated encoding="edtf">0000</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(zeroes_date).fields
        expect(fields.first.values).to eq ['1 BCE']
      end

      it 'does not append CE to dates that are not integers' do
        non_integer_date = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>19xx</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(non_integer_date).fields
        expect(fields.first.values).to eq ['20th century']
      end

      it 'renders BC ranges' do
        bc_range = <<-MODS
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated encoding="edtf" qualifier="approximate" keyDate="yes" point="start">-0249</dateCreated>
              <dateCreated encoding="edtf" qualifier="approximate" point="end">-0099</dateCreated>
            </originInfo>
          </mods>
        MODS

        fields = mods_display_imprint(bc_range).fields
        expect(fields.first.values).to eq ['[ca. 250 BCE-100 BCE]']
      end
    end
  end

  describe 'punctuation' do
    it 'does not duplicate punctuation' do
      fields = mods_display_imprint(punctuation_imprint_fixture).fields
      expect(fields.length).to eq 1
      expect(fields.first.values).to eq ['San Francisco : Chronicle Books, 2015.']
    end
  end

  describe 'place processing' do
    it 'excludes encoded places' do
      fields = mods_display_imprint(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['[Amsterdam]', '[United States]', 'Netherlands'])
    end

    it "translates encoded place if there isn't a text (or non-typed) value available" do
      fields = mods_display_imprint(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to include 'Netherlands'
    end

    it "ignores 'xx' country codes" do
      fields = mods_display_imprint(xx_country_code).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['1994'])
    end
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for mixed content' do
      html = mods_display_imprint(mixed_mods).to_html
      expect(html.scan(%r{<dt>Imprint</dt>}).length).to eq(1)
      expect(html.scan(%r{<dt>Issuance</dt>}).length).to eq(1)
      expect(html.scan(%r{<dt>Date captured</dt>}).length).to eq(1)
      expect(html.scan(/<dd>/).length).to eq(3)
    end
  end
end
