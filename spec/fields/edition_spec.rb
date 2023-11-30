# frozen_string_literal: true

require 'fixtures/imprint_fixtures'

def mods_display_edition(mods_text)
  # create a new MODS from provided string and generate an Imprint field
  ModsDisplay::Edition.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  )
end

def edition_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  mods_display_edition(mods_text).fields.map(&:values).flatten
end

describe ModsDisplay::Edition do
  include ImprintFixtures

  describe 'labels' do
    it 'gets the Edition label by default' do
      expect(mods_display_edition(imprint_mods).fields.first.label).to eq('Edition:')
    end

    it 'uses the Edition label even when display label available' do
      expect(mods_display_edition(display_label).fields.map(&:label)).to eq(['Edition:'])
    end
  end

  describe 'fields' do
    it 'returns edition part of the originInfo' do
      expect(edition_values(imprint_mods)).to eq(['An edition'])
    end
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for mixed content' do
      html = mods_display_edition(imprint_mods).to_html
      expect(html.scan(%r{<dt>Edition</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
