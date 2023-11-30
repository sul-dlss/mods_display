# frozen_string_literal: true

require 'fixtures/imprint_fixtures'

include ImprintFixtures

def mods_display_imprint(mods_text)
  # create a new MODS from provided string and generate an Imprint field
  ModsDisplay::Imprint.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  )
end

describe ModsDisplay::Imprint do
  describe 'labels' do
    it 'gets the Imprint label by default' do
      expect(mods_display_imprint(imprint_mods).fields.first.label).to eq('Imprint:')
    end

    it 'gets the label from non-imprint origin info fields' do
      fields = mods_display_imprint(edition_and_date_mods).fields
      expect(fields.first.label).to eq('Date valid:')
      expect(fields.last.label).to eq('Issuance:')
    end

    it 'gets multiple labels when we have multiple imprint statements' do
      expect(mods_display_imprint(mixed_mods).fields.map(&:label)).to eq(['Imprint:', 'Date captured:', 'Issuance:'])
    end

    it 'uses the displayLabel when available' do
      expect(mods_display_imprint(display_label).fields.map(&:label)).to eq(['TheLabel:', 'IssuanceLabel:'])
    end
  end

  describe 'fields' do
    it 'returns various parts of the imprint' do
      expect(mods_display_imprint(imprint_mods).fields.map(&:values).join(' ')).to eq(
        'An edition - A Place : A Publisher, An Issue Date, Another Date'
      )
    end

    it 'handles the punctuation when the edition is missing' do
      values = mods_display_imprint(no_edition_mods).fields.map(&:values).join(' ')
      expect(values.strip).not_to match(/^-/)
      expect(values).to match(/^A Place/)
    end

    it 'gets the text for non-imprint origin info fields' do
      fields = mods_display_imprint(edition_and_date_mods).fields
      expect(fields.first.values).to eq(['A Valid Date'])
      expect(fields.last.values).to eq(['The Issuance'])
    end

    it 'handles multiple imprint statements properly' do
      values = mods_display_imprint(mixed_mods).fields
      expect(values.length).to eq(3)
      expect(values.map(&:values)).to include(['A Place : A Publisher'])
      expect(values.map(&:values)).to include(['The Issuance'])
      expect(values.map(&:values)).to include(['The Capture Date'])
    end
  end

  describe 'punctuation' do
    it 'does not duplicate punctuation' do
      fields = mods_display_imprint(punctuation_imprint_fixture).fields
      expect(fields.length).to eq 1
      expect(fields.first.values).to eq ['San Francisco : Chronicle Books, 2015.']
    end
  end

  describe 'place processing' do
    it 'excludes encoded places' do
      fields = mods_display_imprint(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['[Amsterdam]', '[United States]', 'Netherlands'])
    end

    it "translates encoded place if there isn't a text (or non-typed) value available" do
      fields = mods_display_imprint(encoded_place).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to include 'Netherlands'
    end

    it "ignores 'xx' country codes" do
      fields = mods_display_imprint(xx_country_code).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['1994'])
    end
  end

  describe 'to_html' do
    it 'has individual dt/dd pairs for multiple imprint statements' do
      html = mods_display_imprint(mixed_mods).to_html
      expect(html.scan(%r{<dt>Imprint</dt>}).length).to eq(1)
      expect(html.scan(%r{<dt>Issuance</dt>}).length).to eq(1)
      expect(html.scan(%r{<dt>Date captured</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(3)
    end
  end
end
