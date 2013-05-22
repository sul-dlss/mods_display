require "spec_helper"
require "fixtures/name_fixtures"
include NameFixtures

def mods_display_name_link(mods_record)
  config = ModsDisplay::Configuration::Base.new do
    link :link_method, '%value%'
  end
  ModsDisplay::Name.new(mods_record, config, TestController.new)
end

def mods_display_name(mods_record)
  ModsDisplay::Name.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Language do
  before(:all) do
    @name = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart></name></mods>", false).plain_name.first
    @conf_name = Stanford::Mods::Record.new.from_str("<mods><name type='conference'><namePart>John Doe</namePart></name></mods>", false).plain_name.first
    @display_form = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><displayForm>Mr. John Doe</displayForm></name></mods>", false).plain_name.first
    @name_with_role = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><role><roleTerm type='text'>Depicted</roleTerm></role></name></mods>", false).plain_name.first
  end
  describe "label" do
    it "should default Creator/Contributor when none is available" do
      mods_display_name(@name).fields.first.label.should == "Creator/Contributor"
    end
    it "should derive the name from the type attribute if one is available" do
      mods_display_name(@conf_name).fields.first.label.should == "Meeting"
    end
  end
  
  describe "fields" do
    it "should use the display form when available" do
      fields = mods_display_name(@display_form).fields
      fields.length.should == 1
      fields.first.values.length.should == 1
      fields.first.values.first.should be_a(ModsDisplay::Name::Person)
      fields.first.values.first.name.should == "Mr. John Doe"
    end
    it "should get the role when present" do
      fields = mods_display_name(@name_with_role).fields
      fields.length.should == 1
      fields.first.values.length.should == 1
      fields.first.values.first.should be_a(ModsDisplay::Name::Person)
      fields.first.values.first.role.should == "Depicted"
    end
  end
  
  describe "to_html" do
    it "should add the role to the name in parens" do
      html = mods_display_name(@name_with_role).to_html
      html.should match(/<dd>John Doe \(Depicted\)<\/dd>/)
    end
    it "should linke the name and not the role if requested" do
      html = mods_display_name_link(@name_with_role).to_html
      html.should match(/<dd><a href='.*\?John Doe'>John Doe<\/a> \(Depicted\)<\/dd>/)
    end
  end
  
end