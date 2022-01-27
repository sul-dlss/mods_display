# frozen_string_literal: true

require 'spec_helper'

def mods_display_language(mods_record)
  ModsDisplay::Language.new(mods_record)
end

describe ModsDisplay::Language do
  before(:all) do
    @language = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><language><languageTerm type='code'>eng</languageTerm></language></mods>"
    ).language
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><language displayLabel='Lang'><languageTerm type='code'>eng</languageTerm></language></mods>"
    ).language
    @no_lang = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><language displayLabel='Lang'><languageTerm type='code'>zzzxxx</languageTerm></language></mods>"
    ).language
    @mixed = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\">
        <language><languageTerm type='text'>ger</languageTerm><languageTerm type='code'>eng</languageTerm></language>
      </mods>"
    ).language
    @multi = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\">
        <language><languageTerm type='code'>ger</languageTerm><languageTerm type='code'>eng</languageTerm></language>
      </mods>"
    ).language
  end

  describe 'fields' do
    it 'returns an array with a label/values object' do
      values = mods_display_language(@display_label).fields
      expect(values.length).to eq(1)
      expect(values.first).to be_a ModsDisplay::Values
      expect(values.first.label).to eq('Lang:')
      expect(values.first.values).to eq(['English'])
    end

    it "does not return any non type='code' languageTerms from the XML" do
      values = mods_display_language(@mixed).fields
      expect(values.length).to eq(1)
      expect(values.first.values).to eq(['English'])
    end

    it 'handles multiple languages correctly' do
      values = mods_display_language(@multi).fields
      expect(values.length).to eq(1)
      expect(values.first.values).to eq(%w[German English])
    end
  end
end
