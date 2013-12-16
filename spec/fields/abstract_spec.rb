require "spec_helper"

def mods_display_abstract(mods_record)
  ModsDisplay::Abstract.new(mods_record, ModsDisplay::Configuration::Base.new, double("controller"))
end

describe ModsDisplay::Abstract do
  before(:all) do
    @link = Stanford::Mods::Record.new.from_str("<mods><abstract>A link to the library (http://library.stanford.edu) should appear here</abstract></mods>", false).abstract
    @email = Stanford::Mods::Record.new.from_str("<mods><abstract>A link to an email address jdoe@example.com should appear here</abstract></mods>", false).abstract
  end
  
  describe "labels" do
    it "should get a default 'Abstract' label" do
      fields = mods_display_abstract(@link).fields
      fields.length.should == 1
      fields.first.label.should == "Abstract:"
    end
  end

  describe "links" do
    it "should turn URLs into links" do
      mods_display_abstract(@link).to_html.should match(/A link to the library \(<a href='http:\/\/library.stanford.edu'>http:\/\/library.stanford.edu<\/a>\) should appear here/)
    end
    it "should turn email addresses into mailto links" do
      mods_display_abstract(@email).to_html.should match(/A link to an email address <a href='mailto:jdoe@example.com'>jdoe@example.com<\/a> should appear here/)
    end
  end
end