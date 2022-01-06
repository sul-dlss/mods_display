require 'spec_helper'

describe ModsDisplay::Extent do
  let(:mods) do
    <<-XML
      <mods>
        <physicalDescription>
          <extent>Extent Value</extent>
          <extent>Extent Value 2</extent>
        </physicalDescription>
      </mods>
    XML
  end

  subject do
    parsed_mods = Stanford::Mods::Record.new.from_str(mods, false).physical_description
    described_class.new(parsed_mods).fields
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
