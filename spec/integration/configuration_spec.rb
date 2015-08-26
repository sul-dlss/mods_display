require "spec_helper"

class TestNoConfigController
  include ModsDisplay::ControllerExtension
end

class TestConfigController
  include ModsDisplay::ControllerExtension
  
  configure_mods_display do
    title do
      label_class 'label-class'
      value_class 'value-class'
      link :link_to_title, "%value%"
    end
    contact do
      ignore!
    end
  end
  
  def link_to_title(title)
    "/path/to/title?#{title}"
  end
end

describe "Configuration" do
  before(:all) do
    xml = "<mods><titleInfo><title>The Title of this Item</title></titleInfo><note type='contact'>jdoe@example.com</note></mods>"
    model = TestModel.new
    model.modsxml = xml
    @no_config_controller = TestNoConfigController.new
    @config_controller = TestConfigController.new
    @html = @config_controller.render_mods_display(model)
  end
  it "should apply the label class" do
    expect(@html).to match(/<dt class='label-class' title=/)
  end
  it "should apply the value class" do
    expect(@html.scan(/<dd class='value-class'>/).length).to eq(1)
  end
  it "should apply the link" do
    @html.scan(/<a href='\/path\/to\/title\?The Title of this Item'>The Title of this Item<\a>/)
  end
  it "should ignore fields if requested" do
    expect(@html.scan(/jdoe@example\.com/).length).to eq(0)
  end
  it "should get overriden configurations" do
    expect(@no_config_controller.mods_display_config.contact.ignore?).to be false
    expect(@config_controller.mods_display_config.contact.ignore?).to be true
  end
  it "should get default configurations when no controller configuration is supplied" do
    expect(@no_config_controller.mods_display_config.note.delimiter).to eq("<br/>")
  end
end