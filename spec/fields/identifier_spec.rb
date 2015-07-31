require "spec_helper"

def mods_display_id(mods_record)
  ModsDisplay::Identifier.new(mods_record, ModsDisplay::Configuration::Base.new, double("controller"))
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
      expect(mods_display_id(@id).fields.first.label).to eq("Identifier:")
    end
    it "should use the displayLabel attribute when one is available" do
      expect(mods_display_id(@display_label).fields.first.label).to eq("Special Label:")
    end
    it "should use get a label from a list of translations" do
      expect(mods_display_id(@issue_label).fields.first.label).to eq("Issue number:")
    end
    it "should use use the raw type attribute if one is present" do
      expect(mods_display_id(@type_label).fields.first.label).to eq("Some other Type:")
    end
  end
  
  describe "fields" do
    it "should handle matching adjacent labels" do
      fields = mods_display_id(@complex_label).fields
      expect(fields.length).to eq(3)
      
      expect(fields.first.label).to eq("Identifier:")
      expect(fields.first.values.length).to eq(2)
      expect(fields.first.values).to eq(["12345", "54321"])
      
      expect(fields[1].label).to eq("Issue number:")
      expect(fields[1].values.length).to eq(1)
      expect(fields[1].values).to eq(["12345"])
      
      expect(fields.last.label).to eq("Identifier:")
      expect(fields.last.values.length).to eq(1)
      expect(fields.last.values).to eq(["98765"])
    end
  end
  
end