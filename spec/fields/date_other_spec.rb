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

  it 'gets correct label' do
    expect(date_other_fields(many_dates).first.label).to eq('Other date:')
  end

  it 'gets contents of dateValid field' do
    expect(date_other_values(many_dates)).to eq(['other 1944'])
  end

  it 'appends the type attribute value in parens' do
    with_type =
      <<~XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <originInfo>
            <dateOther type="phonograph" keyDate="yes" encoding="w3cdtf">1992</dateOther>
          </originInfo>
        </mods>
      XML
    expect(date_other_values(with_type)).to eq(['1992 (phonograph)'])
  end

  it 'ignores type attribute of empty string' do
    type_empty_string =
      <<~XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <originInfo>
            <dateOther type="">1992</dateOther>
          </originInfo>
        </mods>
      XML
    expect(date_other_values(type_empty_string)).to eq(['1992'])
  end

  it 'ignores empty type attribute' do
    type_unassigned =
      <<~XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <originInfo>
            <dateOther type>1992</dateOther>
          </originInfo>
        </mods>
      XML
    expect(date_other_values(type_unassigned)).to eq(['1992'])
  end

  it 'handles multiple values' do
    type_unassigned =
      <<~XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <originInfo>
            <dateOther>5730 [1969 or 1970]</dateOther>
            <dateOther type="hijri">5730</dateOther>
          </originInfo>
        </mods>
      XML
    expect(date_other_values(type_unassigned)).to eq(['5730 [1969 or 1970]', '5730 (hijri)'])
  end

  it 'range value' do
    range_value =
      <<~XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <originInfo>
            <dateOther point="start">20011008</dateOther>
            <dateOther point="end">20011027</dateOther>
          </originInfo>
        </mods>
      XML
    expect(date_other_values(range_value)).to eq(['20011008 - 20011027'])
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
