# frozen_string_literal: true

require 'support/origin_info_date_helpers'

describe ModsDisplay::DateCaptured do
  let(:many_dates) do
    <<~XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <originInfo>
          <dateCreated>created 1725</dateCreated>
          <dateCaptured>captured 1825</dateCaptured>
          <copyrightDate>copyright 1925</copyright>
          <dateIssued>issued 2025</dateIssued>
          <dateModified>modified 2225</dateModified>
          <dateValid>valid 2125</dateValid>
        </originInfo>
      </mods>
    XML
  end

  it 'gets correct label' do
    expect(date_captured_fields(many_dates).first.label).to eq('Date captured:')
  end

  it 'gets contents of dateCaptured field' do
    expect(date_captured_values(many_dates)).to eq(['captured 1825'])
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for capture date' do
      html = described_class.new(
        Stanford::Mods::Record.new.from_str(many_dates).origin_info
      ).to_html
      expect(html.scan(%r{<dt>Date captured</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
