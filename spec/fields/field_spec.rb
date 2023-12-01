# frozen_string_literal: true

require 'support/origin_info_date_helpers'
require 'fixtures/imprint_fixtures'

describe ModsDisplay::Field do
  include ImprintFixtures

  describe '#date_fields' do
    context 'when the date field name is unrecognized' do
      it 'is ignored by mods_display (but likely not stanford-mods)' do
        wacko_date = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateWacko>1825</dateWacko>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(wacko_date)).to be_empty
      end
    end

    context 'when no originInfo fields' do
      it 'is empty' do
        no_origin_info = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <note>foo</note>
          </mods>
        XML
        expect(date_created_values(no_origin_info)).to be_empty
      end
    end

    describe 'labels' do
      it 'gets the labels for origin info date fields' do
        fields = date_created_fields(no_edition_mods)
        expect(fields.map(&:label)).to eq(['Date created:'])
        fields = date_captured_fields(mixed_mods)
        expect(fields.map(&:label)).to eq(['Date captured:'])
      end

      it 'looks up and uses the I18n label for the date field' do
        expect(I18n).to receive(:t).with('mods_display.date_created').and_call_original
        expect(date_created_fields(no_edition_mods).first.label).to eq('Date created:')
        # expect(date_issued_fields(imprint_mods).first.label).to eq('Date issued:')
      end
    end

    context 'when simple date' do
      it 'gets the raw value' do
        simple_date = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>a raw cold 2934</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(simple_date)).to eq(['a raw cold 2934'])
      end
    end

    context 'when qualifier decoration' do
      it "prepends 'ca. ' to approximate date and wraps it in square brackets" do
        expect(date_valid_values(approximate_date)).to eq(['[ca. 1820]'])
      end

      it "appends '?' to questionable date and wraps it in square brackets" do
        expect(date_valid_values(questionable_date)).to eq(['[1820?]'])
      end

      it 'wraps inferred dates in square-brackets' do
        expect(date_valid_values(inferred_date)).to eq(['[1820]'])
      end
    end

    context 'when multiple values' do
      it 'prefer qualified date' do
        expect(date_created_values(dup_qualified_date)).to eq(['[1820?]'])
      end

      it 'prefer non-encoded date' do
        unencoded_and_encoded = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated encoding="marc">1820</dateCreated>
              <dateCreated>[ca. 1820]</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(unencoded_and_encoded)).to eq(['[ca. 1820]'])
      end

      it 'prefer c copyright date' do
        expect(date_created_values(dup_copyright_date)).to eq(['c1820'])
      end

      it 'only return one when no attributes are present' do
        expect(date_created_values(dup_date)).to eq(['1820'])
      end
    end

    describe 'when encoded' do
      context 'when edtf' do
        it 'transforms year zero dates to 1 BCE' do
          year_zero_date = <<~XML
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateCreated encoding="edtf">0</dateCreated>
              </originInfo>
            </mods>
          XML
          expect(date_created_values(year_zero_date)).to eq ['1 BCE']
        end
      end

      context 'when W3CDTF' do
        it 'single year' do
          single_year_date = <<~XML
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateCreated encoding="w3cDtF">2013</dateCreated>
              </originInfo>
            </mods>
          XML
          expect(date_created_values(single_year_date)).to eq ['2013']
        end

        it 'yyyy-mm value becomes month year' do
          month_year = <<~XML
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateCreated encoding="W3CDTF">2013-07</dateCreated>
              </originInfo>
            </mods>
          XML
          expect(date_created_values(month_year)).to eq ['July 2013']
        end

        it 'yyyy-mm-dd value becomes month day, year' do
          year_month_day = <<~XML
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateCreated encoding="W3CdTf">2013-07-10</dateCreated>
              </originInfo>
            </mods>
          XML
          expect(date_created_values(year_month_day)).to eq ['July 10, 2013']
        end

        it 'uses raw value for unparsable value' do
          unparseable = <<~XML
            <mods xmlns="http://www.loc.gov/mods/v3">
              <originInfo>
                <dateCreated encoding="w3cdtf">Jul. 22, 2013</dateCreated>
              </originInfo>
            </mods>
          XML
          expect(date_created_values(unparseable)).to eq ['Jul. 22, 2013']
        end
      end

      context 'when iso8601' do
        it 'handles full dates properly' do
          expect(date_created_values(iso8601_encoded_dates)).to eq(['November 14, 2013'])
        end

        it 'uses raw value for unparsable value' do
          expect(date_modified_values(iso8601_encoded_dates)).to eq(['Jul. 32, 2013'])
        end
      end
    end

    context 'when bad date' do
      it 'empty value is ignored' do
        empty_date = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated/>
            </originInfo>
          </mods>
        XML
        expect(date_created_fields(empty_date)).to be_empty
      end

      it '9999 is ignored' do
        expect(date_modified_values(bad_dates)).to be_empty
      end

      it 'impossible value returns the raw value' do
        expect(date_modified_values(invalid_dates)).to eq(['1920-09-32'])
      end

      it 'value 0000 returns 1 BCE' do
        zeroes_date = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated encoding="edtf">0000</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(zeroes_date)).to eq ['1 BCE']
      end

      it 'ccxx becomes cc+1(th) century' do
        non_integer_date = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>19xx</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(non_integer_date)).to eq ['20th century']
      end

      it 'renders BC ranges' do
        bc_range = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated encoding="edtf" qualifier="approximate" keyDate="yes" point="start">-0249</dateCreated>
              <dateCreated encoding="edtf" qualifier="approximate" point="end">-0099</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(bc_range)).to eq ['[ca. 250 BCE - 100 BCE]']
      end
    end

    describe 'punctuation' do
      # dateIssued
      it 'trailing period (thank you MARC) is left alone' do
        trailing_period = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>2015.</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(trailing_period)).to eq(['2015.'])
      end
    end

    context 'when date range' do
      it "joins start and end point ranges with a '-'" do
        date_range = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated point="end">1825</dateCreated>
              <dateCreated point="start">1820</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(date_range)).to eq(['1820 - 1825'])
      end

      it 'are open, handles properly' do
        open_range = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated point="start">1820</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(open_range)).to eq(['1820 - '])
      end

      it '4 elements of the same date within a range' do
        four_elements = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>[1820-1825]</dateCreated>
              <dateCreated>1824</dateCreated>
              <dateCreated point="start" qualifier="questionable">1820</dateCreated>
              <dateCreated point="end" qualifier="questionable">1825</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(four_elements)).to eq(['[1820 - 1825?]', '1824'])
      end

      it 'with qualifier for a single date' do
        expect(date_issued_values(qualified_imprint_date)).to eq(['[1820?]'])
      end

      it 'with qualifier on two dates' do
        separate_qualifier_range = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated point="start" qualifier="approximate">1880</dateCreated>
              <dateCreated point="end">1906</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(separate_qualifier_range)).to eq ['[ca. 1880] - 1906']
      end

      it 'plus single date in range' do
        date_range = <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>[1820]</dateCreated>
              <dateCreated point="start">1820</dateCreated>
              <dateCreated point="end">1825</dateCreated>
            </originInfo>
          </mods>
        XML
        expect(date_created_values(date_range)).to eq ['1820 - 1825']
      end

      it 'with encoded dates' do
        expect(date_created_values(encoded_date_range)).to eq ['February  1, 2008 - December  2, 2009']
      end

      it 'with BCE and CE dates' do
        expect(date_created_values(bc_ad_imprint_date_fixture)).to eq ['14 BCE - 44 CE']
      end
    end
  end
end
