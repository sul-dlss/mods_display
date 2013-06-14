require "spec_helper"

def html_from_mods(xml)
  model = TestModel.new
  model.modsxml = xml
  TestController.new.render_mods_display(model)
end

describe "HTML Output" do
  before(:all) do
    @multiple_titles = html_from_mods("<mods><titleInfo><title>Main Title</title></titleInfo><titleInfo type='alternative'><title>Alternate Title</title></titleInfo></mods>")
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
end