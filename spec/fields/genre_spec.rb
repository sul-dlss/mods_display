# frozen_string_literal: true

require 'spec_helper'

def mods_display_genre(mods_record)
  ModsDisplay::Genre.new(mods_record)
end

describe ModsDisplay::Abstract do
  before(:all) do
    @genre = Stanford::Mods::Record.new.from_str('<mods xmlns="http://www.loc.gov/mods/v3"><genre>Map Data</genre></mods>').genre
    @downcase = Stanford::Mods::Record.new.from_str('<mods xmlns="http://www.loc.gov/mods/v3"><genre>map data</genre></mods>').genre
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><genre displayLabel='Special label'>Catographic</genre></mods>"
    ).genre
  end

  describe 'labels' do
    it "returns a default 'Genre' label" do
      fields = mods_display_genre(@genre).fields
      expect(fields.length).to eq(1)
      expect(fields.first.label).to eq('Genre:')
    end

    it 'uses a display label when one is available' do
      fields = mods_display_genre(@display_label).fields
      expect(fields.length).to eq(1)
      expect(fields.first.label).to eq('Special label:')
    end
  end

  describe 'fields' do
    it 'capitalizes the first letter in a genre' do
      fields = mods_display_genre(@downcase).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['Map data'])
    end
  end
end
