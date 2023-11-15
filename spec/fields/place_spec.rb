# frozen_string_literal: true

require 'fixtures/imprint_fixtures'

def mods_display_place(mods_text)
  ModsDisplay::Place.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  )
end

def place_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  mods_display_place(mods_text).fields.map(&:values).flatten
end

describe ModsDisplay::Place do
  include ImprintFixtures

  describe 'labels' do
    it 'gets the Place label by default' do
      expect(mods_display_place(imprint_mods).fields.first.label).to eq('Place:')
    end

    it 'uses the Place label even when display label available' do
      expect(mods_display_place(display_label).fields.map(&:label)).to eq(['Place:'])
    end
  end

  describe 'fields' do
    it 'returns the place part of the originInfo' do
      expect(place_values(imprint_mods)).to eq(['A Place'])
    end

    it 'handles multiple values properly' do
      expect(place_values(display_label)).to eq ['One Place', 'Two Place'] # multiple originInfo
      expect(place_values(encoded_place)).to eq ['[Amsterdam]', '[United States]', 'Netherlands'] # not exactly multiple originInfo
    end
  end

  describe 'punctuation' do
    it 'does not keep trailing punctuation' do
      fields = mods_display_place(punctuation_imprint_fixture).fields
      expect(fields.length).to eq 1
      expect(fields.first.values).to eq ['San Francisco']
    end
  end

  describe 'place processing' do
    it 'excludes encoded places' do
      fields = mods_display_place(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['[Amsterdam]', '[United States]', 'Netherlands'])
    end

    it "translates encoded place if there isn't a text (or non-typed) value available" do
      fields = mods_display_place(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to include 'Netherlands'
    end

    it "ignores 'xx' country codes" do
      fields = mods_display_place(xx_country_code).fields
      expect(fields.length).to eq(0)
    end
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for mixed content' do
      html = mods_display_place(mixed_mods).to_html
      expect(html.scan(%r{<dt>Place</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
