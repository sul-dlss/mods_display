require 'spec_helper'

def mods_display_geo(mods_record)
  ModsDisplay::Geo.new(mods_record)
end

describe ModsDisplay::Geo do
  let(:mods) do
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <extension displayLabel="geo">
          <rdf:RDF xmlns:gml="http://www.opengis.net/gml/3.2/" xmlns:dc="http://purl.org/dc/elements/1.1/">
            <rdf:Description>
              <dc:format>image/tiff; format=ArcGRID</dc:format>
              <dc:type>Dataset#Raster</dc:type>
            </rdf:Description>
          </rdf:RDF>
        </extension>
      </mods>
    XML
  end

  subject do
    mods_display_geo(Stanford::Mods::Record.new.from_str(mods).extension).fields
  end

  describe 'labels' do
    it 'is Format' do
      expect(subject.length).to eq(1)
      expect(subject.first.label).to eq('Format:')
    end
  end

  describe 'fields' do
    it 'joins the normalized format and type with a semicolon' do
      expect(subject.length).to eq(1)
      expect(subject.first.values).to eq(['ArcGRID; Raster'])
    end
  end
end
