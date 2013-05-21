require "spec_helper"
require "fixtures/subjects_fixtures"
include SubjectsFixtures

def mods_display_subject(mods_record)
  config = ModsDisplay::Configuration::Subject.new do
    link :link_method, "%value%"
  end
  ModsDisplay::Subject.new(mods_record, config, TestController.new)
end
def mods_display_hierarchical_subject(mods_record)
  config = ModsDisplay::Configuration::Subject.new do
    hierarchical_link true
    link :link_method, "%value%"
  end
  ModsDisplay::Subject.new(mods_record, config, TestController.new)
end

describe ModsDisplay::Subject do
  before(:all) do
    @subject = Stanford::Mods::Record.new.from_str(subjects, false).subject.first
    @emdash_subject = Stanford::Mods::Record.new.from_str(emdash_subjects, false).subject.first
    @geo_subject = Stanford::Mods::Record.new.from_str(hierarchical_geo_subjects, false).subject.first
  end
  describe "fields" do
    it "should split individual child elments of subject into separate parts" do
      fields = mods_display_subject(@subject).fields
      fields.length.should == 1
      fields.first.values.should == ["Jazz", "Japan", "History and criticism"]
    end
    it "should split horizontalized subjects split with an emdash into separate parts" do
      fields = mods_display_subject(@emdash_subject).fields
      fields.length.should == 1
      fields.first.values.should == ["Jazz", "Japan", "History and criticism"]
    end
    it "should handle hierarchicalGeogaphic subjects properly" do
      fields = mods_display_subject(@geo_subject).fields
      fields.length.should == 1
      fields.first.values.should == ["United States", "California", "Stanford"]
    end
  end
  describe "to_html" do
    it "should link the values when requested" do
      html = mods_display_subject(@subject).to_html
      html.should match(/<a href='http:\/\/library.stanford.edu\?Jazz'>Jazz<\/a>/)
      html.should match(/<a href='http:\/\/library.stanford.edu\?Japan'>Japan<\/a>/)
      html.should match(/<a href='http:\/\/library.stanford.edu\?History and criticism'>History and criticism<\/a>/)
    end
    it "does something" do
      html = mods_display_hierarchical_subject(@subject).to_html
      html.should match(/<a href='http:\/\/library.stanford.edu\?Jazz'>Jazz<\/a>/)
      html.should match(/<a href='http:\/\/library.stanford.edu\?Jazz Japan'>Japan<\/a>/)
      html.should match(/<a href='http:\/\/library.stanford.edu\?Jazz Japan History and criticism'>History and criticism<\/a>/)
    end
  end
  
end