# frozen_string_literal: true

describe ModsDisplay::Extent do
  subject do
    parsed_mods = Stanford::Mods::Record.new.from_str(mods).physical_description
    described_class.new(parsed_mods).fields
  end

  let(:mods) do
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <physicalDescription>
          <extent>Extent Value</extent>
          <extent>Extent Value 2</extent>
        </physicalDescription>
      </mods>
    XML
  end

  describe 'label' do
    it 'is "Extent"' do
      expect(subject.first.label).to eq 'Extent:'
    end
  end

  describe 'values' do
    it 'returns the text of the extent element' do
      expect(subject.first.values).to eq ['Extent Value', 'Extent Value 2']
    end
  end
end
