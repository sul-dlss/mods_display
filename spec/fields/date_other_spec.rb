# frozen_string_literal: true

require 'support/origin_info_date_helpers'

describe ModsDisplay::DateOther do
  let(:many_dates) do
    <<~XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <originInfo>
          <dateCreated>created 1725</dateCreated>
          <dateCaptured>captured 1825</dateCaptured>
          <dateOther>other 1944</dateOther>
          <copyrightDate>copyright 1925</copyright>
          <dateIssued>issued 2025</dateIssued>
          <dateValid>valid 2125</dateValid>
        </originInfo>
      </mods>
    XML
  end

  describe '#date_other_fields' do
    it 'gets correct label' do
      expect(date_other_fields(many_dates).first.label).to eq('Other date:')
    end
  end

  describe '#date_other_values' do
    subject { date_other_values(value) }

    context 'with many dates' do
      let(:value) do
        <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateCreated>created 1725</dateCreated>
              <dateCaptured>captured 1825</dateCaptured>
              <dateOther>other 1944</dateOther>
              <copyrightDate>copyright 1925</copyright>
              <dateIssued>issued 2025</dateIssued>
              <dateValid>valid 2125</dateValid>
            </originInfo>
          </mods>
        XML
      end

      it { is_expected.to eq ['other 1944'] }
    end

    context 'with a type attribute' do
      let(:value) do
        <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateOther type="phonograph" keyDate="yes" encoding="w3cdtf">1992</dateOther>
            </originInfo>
          </mods>
        XML
      end

      it { is_expected.to eq ['1992 (phonograph)'] }
    end

    context 'with an type attribute of empty string' do
      let(:value) do
        <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateOther type="">1992</dateOther>
            </originInfo>
          </mods>
        XML
      end

      it { is_expected.to eq ['1992'] }
    end

    context 'with a null type attribute' do
      let(:value) do
        <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateOther type>1992</dateOther>
            </originInfo>
          </mods>
        XML
      end

      it { is_expected.to eq ['1992'] }
    end

    context 'with multiple values' do
      let(:value) do
        <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateOther>5730 [1969 or 1970]</dateOther>
              <dateOther type="hijri">5730</dateOther>
            </originInfo>
          </mods>
        XML
      end

      it { is_expected.to eq ['5730 [1969 or 1970]', '5730 (hijri)'] }
    end

    context 'with a double-ended range' do
      let(:value) do
        <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateOther point="start">20011008</dateOther>
              <dateOther point="end">20011027</dateOther>
            </originInfo>
          </mods>
        XML
      end

      it { is_expected.to eq ['20011008 - 20011027'] }
    end

    context 'with a single-ended range' do
      let(:value) do
        <<~XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <originInfo>
              <dateOther qualifier="approximate" point="end">1925</dateOther>
            </originInfo>
          </mods>
        XML
      end

      it { is_expected.to eq [' - [ca. 1925]'] }
    end
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for valid date' do
      html = described_class.new(
        Stanford::Mods::Record.new.from_str(many_dates).origin_info
      ).to_html
      expect(html.scan(%r{<dt>Other date</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
