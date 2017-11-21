require 'spec_helper'

def mods_display_contents(mods_record)
  ModsDisplay::Contents.new(mods_record, ModsDisplay::Configuration::Base.new, double('controller'))
end

describe ModsDisplay::Contents do
  before(:all) do
    @contents = Stanford::Mods::Record.new.from_str(
      '<mods><tableOfContents>Content Note</tableOfContents></mods>', false
    ).tableOfContents
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods><tableOfContents displayLabel='Special Label'>Content Note</tableOfContents></mods>", false
    ).tableOfContents
  end
  describe 'label' do
    it 'should have a default label' do
      expect(mods_display_contents(@contents).label).to eq('Table of contents:')
    end
    it 'should use the displayLabel attribute when one is available' do
      expect(mods_display_contents(@display_label).label).to eq('Special Label:')
    end
  end
  context 'multi-valued contents' do
    let(:toc) do
      Stanford::Mods::Record.new.from_str(
              '<mods><tableOfContents>Content Note 1 -- Content Note 2</tableOfContents></mods>', false
            ).tableOfContents
    end
    it 'should have one value with "--" marker' do
      mdc = mods_display_contents(toc)
      expect(mdc.fields.first.values).to eq ['Content Note 1 -- Content Note 2']
    end
    it 'should render as a list' do
      html = mods_display_contents(toc).to_html
      expect(html).to include '<dd><ul><li>Content Note 1</li><li>Content Note 2</li></ul></dd>'
    end
  end
end
