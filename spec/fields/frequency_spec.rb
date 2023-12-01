# frozen_string_literal: true

def mods_display_frequency(mods_text)
  ModsDisplay::Frequency.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  )
end

def frequency_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  mods_display_frequency(mods_text).fields.map(&:values).flatten
end

describe ModsDisplay::Frequency do
  # gb089bd2251
  let(:simple_frequency) do
    <<~XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <originInfo>
          <publisher displayLabel="Publisher">Cranfield University</publisher>
          <dateCaptured encoding="iso8601" point="start" keyDate="yes">20121129060351</dateCaptured>
          <frequency>Semiannual</frequency>
      </mods>
    XML
  end

  it 'gets the Frequency label' do
    expect(mods_display_frequency(simple_frequency).fields.map(&:label)).to eq(['Frequency:'])
  end

  describe 'values' do
    it 'gets the contents of frequency field' do
      expect(frequency_values(simple_frequency)).to eq(['Semiannual'])
    end
  end

  describe 'to_html' do
    it 'has dt/dd pari for frequency' do
      html = described_class.new(
        Stanford::Mods::Record.new.from_str(simple_frequency).origin_info
      ).to_html
      expect(html.scan(%r{<dt>Frequency</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
