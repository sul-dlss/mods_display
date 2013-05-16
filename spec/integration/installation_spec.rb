require "spec_helper"

require "stanford-mods"

describe "Installation" do
  before(:all) do
    @pieces_of_data = 1
    title_xml = "<mods><titleInfo><title>The Title of this Item</title></titleInfo></mods>"
    model = TestModel.new
    model.modsxml = title_xml
    controller = TestController.new
    @html = controller.render_mods_display(model)
  end
  it "should return a single <dl>" do
    @html.scan(/<dl>/).length.should == 1
  end
  it "should return a dt/dd pair for each piece of metadata in the mods" do
    @html.scan(/<dt>/).length.should == @pieces_of_data
    @html.scan(/<dd>/).length.should == @pieces_of_data
  end
  it "should return a proper label" do
    @html.scan(/<dt>Title:<\/dt>/).length.should == 1
  end
  it "should return a proper value" do
    @html.scan(/<dd>The Title of this Item<\/dd>/).length.should == 1
  end
end