require "spec_helper"

def mods_display_resource_type(mods_record)
  ModsDisplay::ResourceType.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::ResourceType do
  before(:all) do
    @type = Stanford::Mods::Record.new.from_str("<mods><typeOfResource>Resource Type</typeOfResource></mods>", false).typeOfResource
    @display_label = Stanford::Mods::Record.new.from_str("<mods><typeOfResource displayLabel='Special label'>Resource Type</typeOfResource></mods>", false).typeOfResource
  end
  it "should default to a label of 'Type of resource'" do
    fields = mods_display_resource_type(@type).fields
    fields.length.should == 1
    fields.first.label.should == "Type of resource"
  end
  it "should use the displayLabel attribute when present" do
    fields = mods_display_resource_type(@display_label).fields
    fields.length.should == 1
    fields.first.label.should == "Special label"
  end
end