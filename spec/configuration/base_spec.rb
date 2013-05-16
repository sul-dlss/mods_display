require "spec_helper"

describe ModsDisplay::Configuration::Base do
  it "should set config options w/ a block" do
    config = ModsDisplay::Configuration::Base.new do 
      label_class "testing_label_class"
      value_class "testing_value_class"
    end
    config.label_class.should == "testing_label_class"
    config.value_class.should == "testing_value_class"
  end
  describe "link" do
    it "should return an array with a method name and params" do
      ModsDisplay::Configuration::Base.new do
        link :my_url_generating_method, q: '"%value%"'
      end.link.should == [:my_url_generating_method, {:q => '"%value%"'}]
    end
  end
  describe "delmiter" do
    it "should override the default delimiter" do
      ModsDisplay::Configuration::Base.new do
        delimiter "<br/>"
      end.delimiter.should == "<br/>"
    end
    it "should default to ', '" do
      ModsDisplay::Configuration::Base.new.delimiter.should == ", "
    end
  end
end