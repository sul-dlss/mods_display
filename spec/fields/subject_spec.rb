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
    @subject = Stanford::Mods::Record.new.from_str(subjects, false).subject
    @blank_subject = Stanford::Mods::Record.new.from_str(blank_subject, false).subject
    @emdash_subject = Stanford::Mods::Record.new.from_str(emdash_subjects, false).subject
    @geo_subject = Stanford::Mods::Record.new.from_str(hierarchical_geo_subjects, false).subject
    @name_subject = Stanford::Mods::Record.new.from_str(name_subjects, false).subject
    @complex_subject = Stanford::Mods::Record.new.from_str(complex_subjects, false).subject
    @display_label = Stanford::Mods::Record.new.from_str(display_label_subjects, false).subject
  end
  describe "fields" do
    it "should split individual child elments of subject into separate parts" do
      fields = mods_display_subject(@subject).fields
      fields.length.should == 1
      fields.first.values.should == [["Jazz", "Japan", "History and criticism"]]
    end
    it "should split horizontalized subjects split with an emdash into separate parts" do
      fields = mods_display_subject(@emdash_subject).fields
      fields.length.should == 1
      fields.first.values.should == [["Jazz", "Japan", "History and criticism"]]
    end
    it "should handle hierarchicalGeogaphic subjects properly" do
      fields = mods_display_subject(@geo_subject).fields
      fields.length.should == 1
      fields.first.values.should == [["United States", "California", "Stanford"]]
    end
    it "should handle display labels properly" do
      fields = mods_display_subject(@display_label).fields
      fields.length.should == 3
      fields.first.label.should  == "Subject:"
      fields.first.values.should == [["A Subject", "Another Subject"], ["B Subject", "Another B Subject"]]
      fields[1].label.should     == "Subject Heading:"
      fields[1].values.should    == [["Jazz", "Japan", "History and criticism"]]
      fields.last.label.should   == "Subject:"
      fields.last.values.should  == [["Bay Area", "Stanford"]]
    end
    it "should handle blank subjects properly" do
      mods_display_subject(@blank_subject).fields.should == []
    end
  end

  describe "name subjects" do
    it "should handle name subjects properly" do
      fields = mods_display_subject(@name_subject).fields
      fields.length.should == 1
      fields.first.values.first.first.should be_a(ModsDisplay::Name::Person)
      fields.first.values.first.first.name.should == "John Doe"
      fields.first.values.first.first.roles.should == ["Depicted"]
    end
    it "should link the name (and not the role) correctly" do
      html = mods_display_subject(@name_subject).to_html
      html.should match(/<a href='.*\?John Doe'>John Doe<\/a> \(Depicted\)/)
      html.should match(/<a href='.*\?Anonymous People'>Anonymous People<\/a>/)
    end
    it "should linke the name (and not the role) correctly when linking hierarchicaly" do
      html = mods_display_hierarchical_subject(@name_subject).to_html
      html.should match(/<a href='.*\?John Doe'>John Doe<\/a> \(Depicted\)/)
      html.should match(/<a href='.*\?John Doe Anonymous People'>Anonymous People<\/a>/)
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
    it "should collapse fields into the same label" do
      html = mods_display_subject(@complex_subject).to_html
      html.scan(/<dt title='Subject'>Subject:<\/dt>/).length.should == 1
      html.scan(/<dd>/).length.should == 1
      html.scan(/<br\/>/).length.should == 1
      html.scan(/ &gt; /).length.should == 3
    end
    it "should handle complex display labels" do
      html = mods_display_subject(@display_label).to_html
      html.scan(/<dt title='Subject'>Subject:<\/dt>/).length.should eq 2
      html.scan(/<dt title='Subject Heading'>Subject Heading:<\/dt>/).length.should eq 1
      html.scan(/<dd>/).length.should == 3
    end
  end

end