require 'spec_helper'

def mods_display_contents(mods_record)
  ModsDisplay::Contents.new(mods_record, ModsDisplay::Configuration::Base.new, double('controller'))
end

describe ModsDisplay::Contents do
  before(:all) do
    @contents = Stanford::Mods::Record.new.from_str('<mods><tableOfContents>Content Note</tableOfContents></mods>', false).tableOfContents
    @display_label = Stanford::Mods::Record.new.from_str("<mods><tableOfContents displayLabel='Special Label'>Content Note</tableOfContents></mods>", false).tableOfContents
  end
  describe 'label' do
    it 'should have a default label' do
      expect(mods_display_contents(@contents).label).to eq('Table of contents:')
    end
    it 'should use the displayLabel attribute when one is available' do
      expect(mods_display_contents(@display_label).label).to eq('Special Label:')
    end
  end
end
