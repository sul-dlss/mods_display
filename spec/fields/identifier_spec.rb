require "spec_helper"

def mods_display_id(mods_record)
  ModsDisplay::Identifier.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Note do
  before(:all) do
    @id = Stanford::Mods::Record.new.from_str("<mods><identifier>12345</identifier></mods>", false).identifier
    @display_label = Stanford::Mods::Record.new.from_str("<mods><identifier displayLabel='Special Label'>54321</identifier></mods>", false).identifier
    @issue_label = Stanford::Mods::Record.new.from_str("<mods><identifier type='issue number'>Issue 1</identifier></mods>", false).identifier
    @type_label = Stanford::Mods::Record.new.from_str("<mods><identifier type='Some other Type'>98765</identifier></mods>", false).identifier
    @complex_label = Stanford::Mods::Record.new.from_str("<mods><identifier>12345</identifier><identifier>54321</identifier><identifier type='issue number'>12345</identifier><identifier>98765</identifier></mods>", false).identifier
  end
  describe "label" do
    it "should have a default label" do
      mods_display_id(@id).fields.first.label.should == "Identifier"
    end
    it "should use the displayLabel attribute when one is available" do
      mods_display_id(@display_label).fields.first.label.should == "Special Label"
    end
    it "should use get a label from a list of translations" do
      mods_display_id(@issue_label).fields.first.label.should == "Issue number"
    end
    it "should use use the raw type attribute if one is present" do
      mods_display_id(@type_label).fields.first.label.should == "Some other Type"
    end
  end
  
  describe "fields" do
    it "should handle matching adjacent labels" do
      fields = mods_display_id(@complex_label).fields
      fields.length.should == 3
      
      fields.first.label.should == "Identifier"
      fields.first.values.length.should == 2
      fields.first.values.should == ["12345", "54321"]
      
      fields[1].label.should == "Issue number"
      fields[1].values.length.should == 1
      fields[1].values.should == ["12345"]
      
      fields.last.label.should == "Identifier"
      fields.last.values.length.should == 1
      fields.last.values.should == ["98765"]
    end
  end
  
end