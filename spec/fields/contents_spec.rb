# frozen_string_literal: true

def mods_display_contents(mods_record)
  ModsDisplay::Contents.new(mods_record)
end

describe ModsDisplay::Contents do
  before(:all) do
    @contents = Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3"><tableOfContents>Content Note</tableOfContents></mods>'
    ).tableOfContents
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><tableOfContents displayLabel='Special Label'>Content Note</tableOfContents></mods>"
    ).tableOfContents
  end

  describe 'label' do
    it 'has a default label' do
      expect(mods_display_contents(@contents).label).to eq('Table of contents:')
    end

    it 'uses the displayLabel attribute when one is available' do
      expect(mods_display_contents(@display_label).label).to eq('Special Label:')
    end
  end

  context 'multi-valued contents' do
    let(:toc) do
      Stanford::Mods::Record.new.from_str(
        '<mods xmlns="http://www.loc.gov/mods/v3"><tableOfContents>Content Note 1&#10;Content Note 2</tableOfContents></mods>'
      ).tableOfContents
    end

    it 'has one value with a new-line' do
      mdc = mods_display_contents(toc)
      expect(mdc.fields.first.values).to eq ["Content Note 1\nContent Note 2"]
    end

    it 'renders as a list' do
      html = mods_display_contents(toc).to_html
      expect(html).to include('<p>Content Note 1').and include('<br />Content Note 2</p>')
    end
  end
end
