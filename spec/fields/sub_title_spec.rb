require "spec_helper"

def mods_display_sub_title(mods_record)
  ModsDisplay::SubTitle.new(mods_record, ModsDisplay::Configuration::Base.new, double("controller"))
end

describe ModsDisplay::SubTitle do
  before(:all) do
    @title = Stanford::Mods::Record.new.from_str("<mods><titleInfo><title>Main Title</title></titleInfo><titleInfo><title>Sub Title</title></titleInfo></mods>", false).title_info
  end
  it "omit the main title and only return sub titles" do
    fields = mods_display_sub_title(@title).fields
    fields.length.should == 1
    fields.first.label.should == "Title"
    fields.first.values.should == ["Sub Title"]
    
  end
end