# frozen_string_literal: true

require 'spec_helper'

describe ModsDisplay::Form do
  subject do
    parsed_mods = Stanford::Mods::Record.new.from_str(mods).physical_description
    described_class.new(parsed_mods).fields
  end

  let(:mods) do
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <physicalDescription>
          <form>Form Value</form>
          <form>Form Value 2</form>
        </physicalDescription>
      </mods>
    XML
  end

  describe 'label' do
    it 'is "Form"' do
      expect(subject.first.label).to eq 'Form:'
    end
  end

  describe 'values' do
    it 'returns the text of the form element' do
      expect(subject.first.values).to eq ['Form Value', 'Form Value 2']
    end

    context 'duplicated data' do
      let(:mods) do
        <<-XML
          <mods xmlns="http://www.loc.gov/mods/v3">
            <physicalDescription>
              <form authority="gmd">electronic resource.</form>
              <form authority="zxy">electronicresource!</form>
              <form authority="marccategory">electronic Resource</form>
            </physicalDescription>
          </mods>
        XML
      end

      it 'uses only unique form values, ignore differences in case, punctuation or whitespace' do
        expect(subject.first.values).to contain_exactly('electronic resource.')
      end
    end
  end
end
