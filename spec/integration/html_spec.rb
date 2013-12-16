# encoding: UTF-8
require "spec_helper"

def html_from_mods(xml, locale=nil)
  model = TestModel.new
  model.modsxml = xml
  I18n.locale = locale if locale
  TestController.new.render_mods_display(model)
end

describe "HTML Output" do
  before(:all) do
    @multiple_titles = html_from_mods("<mods><titleInfo><title>Main Title</title></titleInfo><titleInfo type='alternative'><title>Alternate Title</title></titleInfo></mods>")
    @abstract = html_from_mods("<mods><abstract>Hey. I'm an abstract.</abstract></mods>")
    mods = "<mods><titleInfo><title>Main Title</title></titleInfo><abstract>Hey. I'm an abstract.</abstract></mods>"
    @mods = html_from_mods(mods)
    @fr_mods = html_from_mods(mods, :fr)
  end
  after(:all) do
    I18n.locale = :en
  end
  describe "i18n" do
    it "should get the default english translations" do
      expect(@mods.to_html).to match(/<dt title='Title'>Title:<\/dt>/)
    end
    it "should internationalize the labels when translations are available" do
      expect(@fr_mods.to_html).to match(/<dt title='Résumé'>Résumé :<\/dt>/)
    end
    it "should get fallback to the default english translations if a translation is missing" do
      expect(@fr_mods.to_html).to match(/<dt title='Title'>Title:<\/dt>/)
    end
  end
  describe "titles" do
    it "should include both titles it regular display" do
      @multiple_titles.to_html.should include("<dd>Main Title</dd>")
      @multiple_titles.to_html.should include("<dd>Alternate Title</dd>")
    end
    it "should return just the first title in the #title method" do
      @multiple_titles.title.should == ["Main Title"]
    end
    it "should omit the first title and return any remaining titles in the #body" do
      @multiple_titles.body.should_not include("<dd>Main Title</dd>")
      @multiple_titles.body.should     include("<dd>Alternate Title</dd>")
    end
  end
  describe "individual fields" do
    it "should return ModsDispaly::Values for the specefied field" do
      fields = @abstract.abstract
      fields.each do |field|
        field.should be_a ModsDisplay::Values
      end
      fields.length.should eq 1
      fields.first.values.should eq ["Hey. I'm an abstract."]
    end
    it "should return a blank array if no data is available for a specific field" do
      @abstract.genre.should eq []
    end
    it "should not return a field that doesn't exist (and isn't a string)" do
      -> {@abstract.not_a_real_field}.should raise_error NoMethodError
    end
  end
end