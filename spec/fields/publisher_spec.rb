# frozen_string_literal: true

require 'fixtures/imprint_fixtures'

def mods_display_publisher(mods_text)
  ModsDisplay::Publisher.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  )
end

def publisher_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  mods_display_publisher(mods_text).fields.map(&:values).flatten
end

describe ModsDisplay::Publisher do
  include ImprintFixtures

  describe 'labels' do
    it 'gets the Publisher label by default' do
      expect(mods_display_publisher(imprint_mods).fields.first.label).to eq('Publisher:')
    end

    it 'uses the Publisher label even when display label available' do
      expect(mods_display_publisher(display_label).fields.map(&:label)).to eq(['Publisher:'])
    end
  end

  describe 'fields' do
    it 'returns publisher part of the originInfo' do
      expect(publisher_values(imprint_mods)).to eq(['A Publisher'])
    end

    it 'handles multiple values properly' do
      expect(publisher_values(display_label)).to eq ['One Publisher', 'Two Publisher']
    end
  end

  describe 'punctuation' do
    it 'does not include trailing punctuation' do
      fields = mods_display_publisher(punctuation_imprint_fixture).fields
      expect(fields.length).to eq 1
      expect(fields.first.values).to eq ['Chronicle Books']
    end
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for publisher' do
      html = mods_display_publisher(mixed_mods).to_html
      expect(html.scan(%r{<dt>Publisher</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(1)
    end
  end
end
