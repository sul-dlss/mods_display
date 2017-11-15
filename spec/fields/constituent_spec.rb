require 'spec_helper'

describe ModsDisplay::Constituent do
  include ConstituentFixtures

  subject(:constituent) { fields.first }
  let(:constituents) { Stanford::Mods::Record.new.from_str(multi_constituent_fixture, false).related_item }
  let(:fields) do
    ModsDisplay::Constituent.new(constituents,
                                 ModsDisplay::Configuration::Constituent.new,
                                 double('controller')).fields
  end

  describe '#label' do
    it 'uses constituent label' do
      expect(constituent.label).to eq('Constituent:')
    end
  end
  describe '#fields' do
    it 'uses correct fields for constituent metadata' do
      expect(fields.length).to eq(1)
      expect(constituent.values.length).to eq(2)
      expect(constituent.values[0]).to eq 'Polychronicon (epitome and continuation to 1429), ff. 1r - 29v'
      expect(constituent.values[1]).to eq 'Gesta regum ad Henricum VI, ff. 30r - 53r'
    end
  end
end
