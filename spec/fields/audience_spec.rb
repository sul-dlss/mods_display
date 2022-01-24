# frozen_string_literal: true

require 'spec_helper'

def mods_display_audience(mods_record)
  ModsDisplay::Audience.new(mods_record)
end

describe ModsDisplay::Contents do
  before(:all) do
    @audience = Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3"><targetAudience>Audience Note</targetAudience></mods>'
    ).targetAudience
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><targetAudience displayLabel='Special Label'>Audience Note</tableOfContents></mods>"
    ).targetAudience
  end

  describe 'label' do
    it 'has a default label' do
      expect(mods_display_audience(@audience).label).to eq('Target audience:')
    end

    it 'uses the displayLabel attribute when one is available' do
      expect(mods_display_audience(@display_label).label).to eq('Special Label:')
    end
  end
end
