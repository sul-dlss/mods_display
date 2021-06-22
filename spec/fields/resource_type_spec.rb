require 'spec_helper'

def mods_display_resource_type(mods_record)
  ModsDisplay::ResourceType.new(mods_record, ModsDisplay::Configuration::Base.new, double('controller'))
end

describe ModsDisplay::ResourceType do
  before(:all) do
    @type = Stanford::Mods::Record.new.from_str(
      '<mods><typeOfResource>Resource Type</typeOfResource></mods>', false
    ).typeOfResource
    @downcase = Stanford::Mods::Record.new.from_str(
      '<mods><typeOfResource>resource type</typeOfResource></mods>', false
    ).typeOfResource
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods><typeOfResource displayLabel='Special label'>Resource Type</typeOfResource></mods>", false
    ).typeOfResource
  end
  it "should default to a label of 'Type of resource'" do
    fields = mods_display_resource_type(@type).fields
    expect(fields.length).to eq(1)
    expect(fields.first.label).to eq('Type of resource:')
  end
  it 'should use the displayLabel attribute when present' do
    fields = mods_display_resource_type(@display_label).fields
    expect(fields.length).to eq(1)
    expect(fields.first.label).to eq('Special label:')
  end
  it 'passes the field value through' do
    fields = mods_display_resource_type(@downcase).fields
    expect(fields.length).to eq(1)
    expect(fields.first.values).to eq(['resource type'])
  end
end
