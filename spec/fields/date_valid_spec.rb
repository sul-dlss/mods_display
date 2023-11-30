# frozen_string_literal: true

require 'support/origin_info_date_helpers'

describe ModsDisplay::DateValid do
  let(:many_dates) do
    <<~XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <originInfo>
          <dateCreated>created 1725</dateCreated>
          <dateCaptured>captured 1825</dateCaptured>
          <copyrightDate>copyright 1925</copyright>
          <dateIssued>issued 2025</dateIssued>
          <dateValid>valid 2125</dateValid>
        </originInfo>
      </mods>
    XML
  end

  it 'gets correct label' do
    expect(date_valid_fields(approximate_date).first.label).to eq('Date valid:')
  end

  it 'gets contents of dateValid field' do
    expect(date_valid_values(many_dates)).to eq(['valid 2125'])
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for valid date' do
      html = described_class.new(
        Stanford::Mods::Record.new.from_str(many_dates).origin_info
      ).to_html
      expect(html.scan(%r{<dt>Date valid</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
