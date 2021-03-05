# encoding: UTF-8
require 'spec_helper'

def html_from_mods(xml, locale = nil)
  model = TestModel.new
  model.modsxml = xml
  I18n.locale = locale if locale
  I18n.fallbacks[:fr] = [:fr, :en]
  TestController.new.render_mods_display(model)
end

describe 'HTML Output' do
  before(:all) do
    @multiple_titles = html_from_mods(
      <<-MODS
        <mods>
          <titleInfo>
            <title>Main Title</title>
          </titleInfo>
          <titleInfo type='alternative'>
            <title>Alternate Title</title>
          </titleInfo>
        </mods>
      MODS
    )
    @abstract = html_from_mods("<mods><abstract>Hey. I'm an abstract.</abstract></mods>")
    mods = "<mods><titleInfo><title>Main Title</title></titleInfo><abstract>Hey. I'm an abstract.</abstract></mods>"
    @mods = html_from_mods(mods)
    @fr_mods = html_from_mods(mods, :fr)
  end
  after(:all) do
    I18n.locale = :en
  end
  describe 'i18n' do
    it 'should get the default english translations' do
      expect(@mods.to_html).to match(%r{<dt title='Title'>Title:</dt>})
    end
    it 'should internationalize the labels when translations are available' do
      expect(@fr_mods.to_html).to match(%r{<dt title='Résumé'>Résumé :</dt>})
    end
    it 'should get fallback to the default english translations if a translation is missing' do
      expect(@fr_mods.to_html).to match(%r{<dt title='Title'>Title:</dt>})
    end
  end
  describe 'titles' do
    it 'should include both titles it regular display' do
      expect(@multiple_titles.to_html).to include('<dd>Main Title</dd>')
      expect(@multiple_titles.to_html).to include('<dd>Alternate Title</dd>')
    end
    it 'should return just the first title in the #title method' do
      expect(@multiple_titles.title).to eq(['Main Title'])
    end
    it 'should omit the first title and return any remaining titles in the #body' do
      expect(@multiple_titles.body).not_to include('<dd>Main Title</dd>')
      expect(@multiple_titles.body).to include('<dd>Alternate Title</dd>')
    end

    it 'should allow access to the subTitle independently from the title (for use with #body or fields)' do
      sub_title = @multiple_titles.subTitle
      expect(sub_title.length).to eq 1
      expect(sub_title.first).to be_a ModsDisplay::Values
      expect(sub_title.first.label).to match(/^Alternative title/i)
      expect(sub_title.first.values).to eq(['Alternate Title'])
    end
  end
  describe 'individual fields' do
    it 'should return ModsDispaly::Values for the specefied field' do
      fields = @abstract.abstract
      fields.each do |field|
        expect(field).to be_a ModsDisplay::Values
      end
      expect(fields.length).to eq 1
      expect(fields.first.values).to eq ["Hey. I'm an abstract."]
    end
    it 'should return a blank array if no data is available for a specific field' do
      expect(@abstract.genre).to eq []
    end
    it "should not return a field that doesn't exist (and isn't a string)" do
      expect { @abstract.not_a_real_field }.to raise_error NoMethodError
    end
  end
  describe 'individual fields' do
    it 'should return ModsDispaly::Class when raw is specified' do
      expect(@abstract.abstract(raw: true)).to be_a ModsDisplay::Abstract
    end
  end
end
