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
  ModsDisplay::Name.new(mods_record, ModsDisplay::Configuration::Base.new, double("controller"))
end

describe ModsDisplay::Language do
  before(:all) do
    @name = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart></name></mods>", false).plain_name
    @blank_name = Stanford::Mods::Record.new.from_str("<mods><name><namePart/><role><roleTerm></roleTerm></role></name></mods>", false).plain_name
    @primary_name = Stanford::Mods::Record.new.from_str("<mods><name usage='primary'><namePart>John Doe</namePart><role><roleTerm>lithographer</roleTerm></role></name></mods>", false).plain_name
    @contributor = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><role><roleTerm>lithographer</roleTerm></role></name></mods>", false).plain_name
    @encoded_role = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><role><roleTerm type='code' authority='marcrelator'>ltg</roleTerm></role></name></mods>", false).plain_name
    @mixed_role = Stanford::Mods::Record.new.from_str("<mods><name><role><roleTerm>publisher</roleTerm></role><namePart>John Doe</namePart><role><roleTerm type='text' authority='marcrelator'>engraver</roleTerm></role></name></mods>", false).plain_name
    @numeral_toa = Stanford::Mods::Record.new.from_str("<mods><name><namePart>Unqualfieid</namePart><namePart type='termsOfAddress'>XVII, ToA</namePart><namePart type='date'>date1-date2</namePart><namePart type='given'>Given Name</namePart><namePart type='family'>Family Name</namePart></name></mods>", false).plain_name
    @simple_toa = Stanford::Mods::Record.new.from_str("<mods><name><namePart>Unqualfieid</namePart><namePart type='termsOfAddress'>Ier, empereur</namePart><namePart type='date'>date1-date2</namePart><namePart type='given'>Given Name</namePart><namePart type='family'>Family Name</namePart></name></mods>", false).plain_name
    @display_form = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><displayForm>Mr. John Doe</displayForm></name></mods>", false).plain_name
    @collapse_label = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart></name><name><namePart>Jane Doe</namePart></name></mods>", false).plain_name
    @complex_labels = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart></name><name><namePart>Jane Doe</namePart><role><roleTerm>lithographer</roleTerm></role></name><name><namePart>John Dough</namePart></name><name><namePart>Jane Dough</namePart></name></mods>", false).plain_name
    @complex_roles = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><role><roleTerm type='text'>Depicted</roleTerm><roleTerm type='code'>dpt</roleTerm></role></name></mods>", false).plain_name
    @name_with_role = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><role><roleTerm type='text'>Depicted</roleTerm></role></name></mods>", false).plain_name
    @multiple_roles = Stanford::Mods::Record.new.from_str("<mods><name><namePart>John Doe</namePart><role><roleTerm type='text'>Depicted</roleTerm></role><role><roleTerm type='text'>Artist</roleTerm></role></name></mods>", false).plain_name
  end
  describe "label" do
    it "should default Author/Creator when no role is available" do
      mods_display_name(@name).fields.first.label.should == "Author/Creator:"
    end
    it "should label 'Author/Creator' for primary authors" do
      mods_display_name(@primary_name).fields.first.label.should == "Author/Creator:"
    end
    it "should apply contributor labeling to all non blank/author/creator roles" do
      mods_display_name(@contributor).fields.first.label.should == "Contributor:"
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
    it "should not add blank names" do
      mods_display_name(@blank_name).fields.should == []
    end
    it "should not delimit given name and termsOfAddress (that begin w/ roman numerals) with a comma" do
      fields = mods_display_name(@numeral_toa).fields
      fields.length.should == 1
      fields.first.values.length.should == 1
      fields.first.values.first.to_s.should_not match /Given Name, XVII/
      fields.first.values.first.to_s.should match /Given Name XVII/
    end
    it "should delimit given name and termsOfAddress (that DO NOT begin w/ roman numerals) with a comma" do
      fields = mods_display_name(@simple_toa).fields
      fields.length.should == 1
      fields.first.values.length.should == 1
      fields.first.values.first.to_s.should match /Given Name, Ier, empereur/
      fields.first.values.first.to_s.should_not match /Given Name Ier, empereur/
    end
    it "should collapse adjacent matching labels" do
      fields = mods_display_name(@collapse_label).fields
      fields.length.should == 1
      fields.first.label.should == "Author/Creator:"
      fields.first.values.each do |val|
        ["John Doe", "Jane Doe"].should include val.to_s
      end
    end
    it "should perseve order and separation of non-adjesent matching labels" do
      fields = mods_display_name(@complex_labels).fields

      fields.length.should == 3
      fields.first.label.should == "Author/Creator:"
      fields.first.values.length.should == 1
      fields.first.values.first.to_s.should == "John Doe"
      
      fields[1].label.should == "Contributor:"
      fields[1].values.length.should == 1
      fields[1].values.first.name.should == "Jane Doe"
      fields[1].values.first.roles.should == ["lithographer"]

      fields.last.label.should == "Author/Creator:"
      fields.last.values.length.should == 2
      fields.last.values.each do |val|
        ["Jane Dough", "John Dough"].should include val.to_s
      end
    end
    describe "roles" do
      it "should get the role when present" do
        fields = mods_display_name(@name_with_role).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.should be_a(ModsDisplay::Name::Person)
        fields.first.values.first.roles.should == ["Depicted"]
      end
      it "should decode encoded roleTerms when no text (or non-typed) roleTerm is available" do
        fields = mods_display_name(@encoded_role).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.to_s.should == "John Doe (Lithographer)"
      end
      it "should get the type='text' role before an untyped role" do
        fields = mods_display_name(@mixed_role).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.roles.should == ["engraver"]
      end
      it "should be handled correctly when there are more than one" do
        fields = mods_display_name(@multiple_roles).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.roles.should == ["Depicted", "Artist"]
      end
      it "should handle code and text roleTerms together correctly" do
        fields = mods_display_name(@complex_roles).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.roles.should == ["Depicted"]
      end
      it "should comma seperate multiple roles" do
        fields = mods_display_name(@multiple_roles).fields
        fields.length.should == 1
        fields.first.values.length.should == 1
        fields.first.values.first.to_s.should == "John Doe (Depicted, Artist)"
      end
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