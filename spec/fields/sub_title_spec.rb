# frozen_string_literal: true

require 'spec_helper'

def mods_display_sub_title(mods_record)
  ModsDisplay::SubTitle.new(mods_record)
end

describe ModsDisplay::SubTitle do
  before(:all) do
    @title = Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3"><titleInfo><title>Main Title</title></titleInfo><titleInfo><title>Sub Title</title></titleInfo></mods>'
    ).title_info
  end

  it 'omit the main title and only return sub titles' do
    fields = mods_display_sub_title(@title).fields
    expect(fields.length).to eq(1)
    expect(fields.first.label).to eq('Title:')
    expect(fields.first.values).to eq(['Sub Title'])
  end
end
