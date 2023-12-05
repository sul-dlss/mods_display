# frozen_string_literal: true

require 'spec_helper'

describe ModsDisplay::ReferenceTitle do
  def mods_display_item(mods_record)
    ModsDisplay::ReferenceTitle.new(Stanford::Mods::Record.new.from_str(mods_record).title_info)
  end

  def reference
    <<-XML
      <mods xmlns="http://www.loc.gov/mods/v3">
        <titleInfo>The title</titleInfo>
        <note>124</note>
        <originInfo>
          <dateOther>DATE</dateOther>
        </originInfo>
      </mods>
    XML
  end

  describe 'label' do
    it 'gets the reference label' do
      expect(mods_display_item(reference).fields.first.label).to eq('Title:')
    end
  end

  describe 'fields' do
    def blank_item
      <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
        </mods>
      XML
    end

    it 'does not return empty links when there is no title' do
      expect(mods_display_item(blank_item).fields).to eq([])
    end

    it 'concats the isReferencedBy related item title with other metadata' do
      fields = mods_display_item(reference).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['The title DATE 124'])
    end
  end
end
