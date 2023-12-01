# frozen_string_literal: true

require 'support/origin_info_date_helpers'

describe ModsDisplay::CopyrightDate do
  let(:many_dates) do
    <<~XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <originInfo>
          <dateCreated>created 1725</dateCreated>
          <dateCaptured>captured 1825</dateCaptured>
          <copyrightDate>copyright 1925</copyrightDate>
          <dateIssued>issued 2025</dateIssued>
          <dateModified>modified 2225</dateModified>
          <dateValid>valid 2125</dateValid>
        </originInfo>
      </mods>
    XML
  end

  it 'gets correct label' do
    expect(copyright_date_fields(many_dates).first.label).to eq('Copyright date:')
  end

  it 'gets contents of copyrightDate field' do
    expect(copyright_date_values(many_dates)).to eq(['copyright 1925'])
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for date issued' do
      html = described_class.new(
        Stanford::Mods::Record.new.from_str(many_dates).origin_info
      ).to_html
      expect(html.scan(%r{<dt>Copyright date</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
