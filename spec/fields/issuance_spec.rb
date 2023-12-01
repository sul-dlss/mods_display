# frozen_string_literal: true

require 'fixtures/imprint_fixtures'

def mods_display_issuance(mods_text)
  ModsDisplay::Issuance.new(
    Stanford::Mods::Record.new.from_str(mods_text).origin_info
  )
end

def issuance_values(mods_text)
  # without flatten, this returns an outer array for fields and an inner array for values
  mods_display_issuance(mods_text).fields.map(&:values).flatten
end

describe ModsDisplay::Issuance do
  include ImprintFixtures

  let(:simple_issuance) do
    <<~XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <originInfo>
          <publisher>Publisher</publisher>
          <issuance>single unit</issuance>
        </originInfo>
      </mods>
    XML
  end

  let(:multiple_issuance) do
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <originInfo>
          <publisher>Publisher One</publisher>
          <issuance>multipart monograph</issuance>
        </originInfo>
        <originInfo>
          <publisher>Publisher Two</publisher>
          <issuance>multipart monograph</issuance>
        </originInfo>
      </mods>
    XML
  end

  describe 'labels' do
    it 'gets the Issuance label by default' do
      expect(mods_display_issuance(simple_issuance).fields.map(&:label)).to eq(['Issuance:'])
    end

    it 'gets the label from non-imprint origin info fields' do
      expect(mods_display_issuance(edition_and_date_mods).fields.map(&:label)).to eq(['Issuance:'])
    end

    it 'uses the displayLabel when available' do
      expect(mods_display_issuance(display_label).fields.map(&:label)).to eq(['IssuanceLabel:'])
    end

    it 'has only one label for multiple originInfo elements with issuance' do
      expect(mods_display_issuance(multiple_issuance).fields.map(&:label)).to eq(['Issuance:'])
    end
  end

  describe 'values' do
    it 'gets the contents of issuance field' do
      expect(issuance_values(edition_and_date_mods)).to eq(['The Issuance'])
    end

    it 'has multiple values for multiple issuance elements' do
      expect(issuance_values(multiple_issuance)).to eq(['multipart monograph', 'multipart monograph'])
    end
  end

  describe 'to_html' do
    it 'has dt/dd for issuance' do
      html = described_class.new(
        Stanford::Mods::Record.new.from_str(multiple_issuance).origin_info
      ).to_html
      expect(html.scan(%r{<dt>Issuance</dt>}).length).to eq(1)
      expect(html.scan('<dd>').length).to eq(2)
    end
  end
end
