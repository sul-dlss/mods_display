require "spec_helper"

class TestConfigController
  include ModsDisplay::ControllerExtension
  
  configure_mods_display do
    title do
      label_class 'label-class'
      value_class 'value-class'
      link :link_to_title, "%value%"
    end
  end
  
  def link_to_title(title)
    "/path/to/title?#{title}"
  end
end

describe "Configuration" do
  before(:all) do
    xml = "<mods><titleInfo><title>The Title of this Item</title></titleInfo></mods>"
    model = TestModel.new
    model.modsxml = xml
    controller = TestConfigController.new
    @html = controller.render_mods_display(model)
  end
  it "should apply the label class" do
    @html.scan(/<dt class='label-class' title=/).length.should == 1
  end
  it "should apply the value class" do
    @html.scan(/<dd class='value-class'>/).length.should == 1
  end
  it "should apply the link" do
    @html.scan(/<a href='\/path\/to\/title\?The Title of this Item'>The Title of this Item<\a>/)
  end
  
end