# frozen_string_literal: true

require 'fixtures/cartographics_fixtures'
include CartographicsFixtures

def mods_display_cartographics(mods)
  ModsDisplay::Cartographics.new(mods)
end

describe ModsDisplay::Cartographics do
  before(:all) do
    @cart = Stanford::Mods::Record.new.from_str(full_cartographic).subject
    @scale_only = Stanford::Mods::Record.new.from_str(scale_only).subject
    @no_scale = Stanford::Mods::Record.new.from_str(no_scale_cartographic).subject
    @coordinates = Stanford::Mods::Record.new.from_str(coordinates_only).subject
  end

  describe 'values' do
    it 'gets the full cartographic note' do
      values = mods_display_cartographics(@cart).fields
      expect(values.length).to eq(1)
      expect(values.first.values).to eq(['The scale ; the projection the coordinates'])
    end

    it 'puts a scale not given note if no scale is present' do
      values = mods_display_cartographics(@no_scale).fields
      expect(values.length).to eq(1)
      expect(values.first.values).to eq(['the projection the coordinates'])
    end

    it 'handles when there is only a scale note' do
      values = mods_display_cartographics(@scale_only).fields
      expect(values.length).to eq(1)
      expect(values.first.values).to eq(['The scale'])
    end

    it 'handles when only one post-scale piece of the data is available' do
      values = mods_display_cartographics(@coordinates).fields
      expect(values.length).to eq(1)
      expect(values.first.values).to eq(['the coordinates'])
    end
  end
end
