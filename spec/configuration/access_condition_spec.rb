require "spec_helper"

describe ModsDisplay::Configuration::AccessCondition do
  it "should default ignore? to true" do
    ModsDisplay::Configuration::AccessCondition.new.ignore?.should be_true
  end
  it "should set ignore? to false when the display! configuration is set" do
    ModsDisplay::Configuration::AccessCondition.new{ display! }.ignore?.should be_false
  end
end
