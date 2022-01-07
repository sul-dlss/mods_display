require 'spec_helper'

describe 'Installation' do
  before(:all) do
    @pieces_of_data = 1
    title_xml = '<mods><titleInfo><title>The Title of this Item</title></titleInfo></mods>'
    model = TestModel.new
    model.modsxml = title_xml
    controller = TestController.new
    @html = controller.render_mods_display(model).to_html
  end
  it 'should return a single <dl>' do
    expect(@html.scan(/<dl>/).length).to eq(1)
    expect(@html.scan(%r{</dl>}).length).to eq(1)
  end
  it 'should return a dt/dd pair for each piece of metadata in the mods' do
    expect(@html.scan(/<dt/).length).to eq(@pieces_of_data)
    expect(@html.scan(/<dd>/).length).to eq(@pieces_of_data)
  end
  it 'should return a proper label' do
    expect(@html.scan(%r{<dt>Title</dt>}).length).to eq(1)
  end
  it 'should return a proper value' do
    expect(@html.scan(%r{<dd>\s*The Title of this Item\s*</dd>}).length).to eq(1)
  end
end
