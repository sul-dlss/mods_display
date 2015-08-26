require "spec_helper"

describe ModsDisplay::Configuration::AccessCondition do
  it "should default ignore? to true" do
    expect(ModsDisplay::Configuration::AccessCondition.new.ignore?).to be true
  end
  it "should set ignore? to false when the display! configuration is set" do
    expect(ModsDisplay::Configuration::AccessCondition.new{ display! }.ignore?).to be false
  end
end
