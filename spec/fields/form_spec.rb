require 'spec_helper'

describe ModsDisplay::Form do
  let(:mods) do
    <<-XML
      <mods>
        <physicalDescription>
          <form>Form Value</form>
        </physicalDescription>
      </mods>
    XML
  end

  subject do
    parsed_mods = Stanford::Mods::Record.new.from_str(mods, false).physical_description
    described_class.new(parsed_mods, ModsDisplay::Configuration::Base.new, double('controller')).fields
  end

  describe 'label' do
    it 'is "Form"' do
      expect(subject.first.label).to eq 'Form:'
    end
  end

  describe 'values' do
    it 'returns the text of the form element' do
      expect(subject.first.values).to eq ['Form Value']
    end
  end
end
