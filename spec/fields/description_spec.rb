# frozen_string_literal: true

require 'spec_helper'

def mods_display_description(mods)
  ModsDisplay::Description.new(mods)
end

describe ModsDisplay::Description do
  before(:all) do
    @form = Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3"><physicalDescription><note>Description Note</note></physicalDescription></mods>'
    ).physical_description
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\">
        <physicalDescription displayLabel='SpecialLabel'><note>Description Note</note></physicalDescription>
       </mods>"
    ).physical_description
    @child_display_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><physicalDescription><note displayLabel='Note Label'>Description Note</note></physicalDescription></mods>"
    ).physical_description
    @mixed = Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3">
        <physicalDescription>
          <note>Description Note</note>
          <digitalOrigin>Digital Origin Note</digitalOrigin>
        </physicalDescription>
       </mods>'
    ).physical_description
  end

  describe 'labels' do
    it 'uses the displayLabel if one is provided' do
      expect(mods_display_description(@display_label).fields.first.label).to eq('SpecialLabel:')
    end

    it 'gets the default label for a child element' do
      expect(mods_display_description(@form).fields.first.label).to eq('Note:')
    end

    it 'gets multiple lables for mixed content' do
      expect(mods_display_description(@mixed).fields.map(&:label)).to eq(['Note:', 'Digital origin:'])
    end

    it 'gets the display label from child elements' do
      expect(mods_display_description(@child_display_label).fields.map(&:label)).to eq(['Note Label:'])
    end
  end

  describe 'fields' do
    it 'gets the value from a field in physicalDescription' do
      expect(mods_display_description(@form).fields.first.values).to eq(['Description Note'])
    end

    it 'gets multiple values for mixed content' do
      expect(mods_display_description(@mixed).fields.map(&:values)).to eq(
        [['Description Note'], ['Digital Origin Note']]
      )
    end
  end
end
