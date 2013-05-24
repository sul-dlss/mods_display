require "spec_helper"

def mods_display_abstract(mods_record)
  ModsDisplay::Abstract.new(mods_record, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Abstract do
  before(:all) do
    @link = Stanford::Mods::Record.new.from_str("<mods><abstract>A link to the library (http://library.stanford.edu) should appear here</abstract></mods>", false).abstract
    @email = Stanford::Mods::Record.new.from_str("<mods><abstract>A link to an email address jdoe@example.com should appear here</abstract></mods>", false).abstract
  end

  describe "links" do
    it "should turn URLs into links" do
      mods_display_abstract(@link).fields.first.values.first.should match(/\(<a href='http:\/\/library.stanford.edu'>http:\/\/library.stanford.edu<\/a>\)/)
    end
    it "should turn email addresses into mailto links" do
      mods_display_abstract(@email).fields.first.values.first.should match(/<a href='mailto:jdoe@example.com'>jdoe@example.com<\/a>/)
    end
  end
end