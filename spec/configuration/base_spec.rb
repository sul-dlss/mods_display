require 'spec_helper'

describe ModsDisplay::Configuration::Base do
  it 'should set config options w/ a block' do
    config = ModsDisplay::Configuration::Base.new do
      label_class 'testing_label_class'
      value_class 'testing_value_class'
    end
    expect(config.label_class).to eq('testing_label_class')
    expect(config.value_class).to eq('testing_value_class')
  end
  describe 'link' do
    it 'should return an array with a method name and params' do
      expect(ModsDisplay::Configuration::Base.new do
        link :my_url_generating_method, q: '"%value%"'
      end.link).to eq([:my_url_generating_method, { q: '"%value%"' }])
    end
  end
  describe 'delmiter' do
    it 'should override the default delimiter' do
      expect(ModsDisplay::Configuration::Base.new do
        delimiter '<br/>'
      end.delimiter).to eq('<br/>')
    end
    it "should default to ', '" do
      expect(ModsDisplay::Configuration::Base.new.delimiter).to eq(', ')
    end
  end
  describe 'ignore' do
    it 'should be set to true if the #ignore! method is called' do
      expect(ModsDisplay::Configuration::Base.new do
        ignore!
      end.ignore?).to be true
    end
    it 'should be false by default' do
      expect(ModsDisplay::Configuration::Base.new.ignore?).to be false
    end
  end
end
