# frozen_string_literal: true

describe ModsDisplay::Location do
  let(:location_mods) do
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <location>
          <shelfLocator>On Shelf A</shelfLocator>
        </location>
      </mods>
    XML
  end

  let(:url_mods) do
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <location>
          <url displayLabel='Stanford University Library'>http://library.stanford.edu</url>
        </location>
        <location displayLabel='PURL'>
          <url>http://purl.stanford.edu</url>
        </location>
      </mods>
    XML
  end

  let(:repository_mods) do
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <location>
          <physicalLocation type='repository'>Location Field</physicalLocation>
        </location>
      </mods>
    XML
  end

  let(:location) do
    mods = Stanford::Mods::Record.new.from_str(location_mods).location
    described_class.new(mods).fields
  end

  let(:urls) do
    mods = Stanford::Mods::Record.new.from_str(url_mods).location
    described_class.new(mods).fields
  end

  let(:repository_label) do
    mods = Stanford::Mods::Record.new.from_str(repository_mods).location
    described_class.new(mods).fields
  end

  describe 'label' do
    it 'has a default label' do
      expect(location.first.label).to eq 'Location:'
    end

    it 'handles the URL labels correctly' do
      expect(urls.map(&:label)).to eq ['Location:', 'PURL:']
    end

    it 'uses get a label from a list of translations' do
      expect(repository_label.first.label).to eq 'Repository:'
    end
  end

  describe 'fields' do
    describe 'URLs' do
      it 'links and use the displayLabel as text' do
        expect(urls.length).to eq(2)
        field = urls.find { |f| f.label == 'Location:' }
        expect(field.values).to eq(["<a href='http://library.stanford.edu'>Stanford University Library</a>"])
      end

      it 'links the URL itself in the absence of a displayLabel on the url element' do
        expect(urls.length).to eq(2)
        field = urls.find { |f| f.label == 'PURL:' }
        expect(field.values).to eq(["<a href='http://purl.stanford.edu'>http://purl.stanford.edu</a>"])
      end
    end
  end
end
