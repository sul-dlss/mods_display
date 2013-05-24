require "spec_helper"
require "fixtures/cartographics_fixtures"
include CartographicsFixtures

def mods_display_cartographics(mods)
  ModsDisplay::Cartographics.new(mods, ModsDisplay::Configuration::Base.new, mock("controller"))
end

describe ModsDisplay::Cartographics do
  before(:all) do
    @cart = Stanford::Mods::Record.new.from_str(full_cartographic, false).subject
    @scale_only = Stanford::Mods::Record.new.from_str(scale_only, false).subject
    @no_scale = Stanford::Mods::Record.new.from_str(no_scale_cartographic, false).subject
    @coordinates = Stanford::Mods::Record.new.from_str(coordinates_only, false).subject
  end
  describe "values" do
    it "should get the full cartographic note" do
      values = mods_display_cartographics(@cart).fields
      values.length.should == 1
      values.first.values.should == ["The scale ; the projection the coordinates"]
    end
    it "should put a scale not given note if no scale is present" do
      values = mods_display_cartographics(@no_scale).fields
      values.length.should == 1
      values.first.values.should == ["Scale not given ; the projection the coordinates"]
    end
    it "should handle when there is only a scale note" do
      values = mods_display_cartographics(@scale_only).fields
      values.length.should == 1
      values.first.values.should == ["The scale"]
    end
    it "should handle when only one post-scale piece of the data is available" do
      values = mods_display_cartographics(@coordinates).fields
      values.length.should == 1
      values.first.values.should == ["Scale not given ; the coordinates"]
    end
  end

end