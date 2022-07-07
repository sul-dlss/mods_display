# frozen_string_literal: true

require 'spec_helper'

def html_from_mods(xml, locale = nil)
  I18n.locale = locale if locale
  I18n.fallbacks[:fr] = %i[fr en]
  ModsDisplay::Record.new(xml).mods_display_html
end

describe 'HTML Output' do
  before(:all) do
    @multiple_titles = html_from_mods(
      <<-MODS
        <mods xmlns="http://www.loc.gov/mods/v3">
          <titleInfo>
            <title>Main Title</title>
          </titleInfo>
          <titleInfo type='alternative'>
            <title>Alternate Title</title>
          </titleInfo>
          <titleInfo type='alternative'>
            <title>Second Alternate Title</title>
          </titleInfo>
        </mods>
      MODS
    )
    @abstract = html_from_mods("<mods xmlns=\"http://www.loc.gov/mods/v3\"><abstract>Hey. I'm an abstract.</abstract></mods>")
    mods = "<mods xmlns=\"http://www.loc.gov/mods/v3\"><titleInfo><title>Main Title</title></titleInfo><abstract>Hey. I'm an abstract.</abstract></mods>"
    @mods = html_from_mods(mods)
    @fr_mods = html_from_mods(mods, :fr)
  end

  after(:all) do
    I18n.locale = :en
  end

  describe 'i18n' do
    it 'gets the default english translations' do
      expect(@mods.to_html).to match(%r{<dt>Title</dt>})
    end

    it 'internationalizes the labels when translations are available' do
      expect(@fr_mods.to_html).to match(%r{<dt>Résumé </dt>})
    end

    it 'gets fallback to the default english translations if a translation is missing' do
      expect(@fr_mods.to_html).to match(%r{<dt>Title</dt>})
    end
  end

  describe 'titles' do
    it 'includes all titles it regular display' do
      expect(@multiple_titles.to_html).to match(%r{<dd>\s*Main Title\s*</dd>})
      expect(@multiple_titles.to_html).to match(%r{<dd>\s*Alternate Title<br />Second Alternate Title\s*</dd>})
    end

    it 'returns just the first title in the #title method' do
      expect(@multiple_titles.title).to eq(['Main Title'])
    end

    it 'omits the first title and return any remaining titles in the #body' do
      expect(@multiple_titles.body).not_to match(%r{<dd>\s*Main Title\s*</dd>})
      expect(@multiple_titles.body).to match(%r{<dd>\s*Alternate Title<br />Second Alternate Title\s*</dd>})
    end

    it 'allows access to the subTitle independently from the title (for use with #body or fields)' do
      sub_title = @multiple_titles.subTitle
      expect(sub_title.length).to eq 1
      expect(sub_title.first).to be_a ModsDisplay::Values
      expect(sub_title.first.label).to match(/^Alternative title/i)
      expect(sub_title.first.values).to eq(['Alternate Title', 'Second Alternate Title'])
    end
  end

  describe 'individual fields' do
    it 'returns ModsDispaly::Values for the specefied field' do
      fields = @abstract.abstract
      fields.each do |field|
        expect(field).to be_a ModsDisplay::Values
      end
      expect(fields.length).to eq 1
      expect(fields.first.values).to eq ["Hey. I'm an abstract."]
    end

    it 'returns a blank array if no data is available for a specific field' do
      expect(@abstract.genre).to eq []
    end

    it "does not return a field that doesn't exist (and isn't a string)" do
      expect { @abstract.not_a_real_field }.to raise_error NoMethodError
    end
  end

  describe 'individual fields' do
    it 'returns ModsDispaly::Class when raw is specified' do
      expect(@abstract.abstract(raw: true)).to be_a ModsDisplay::Abstract
    end
  end

  describe 'embedded html' do
    subject(:html) { html_from_mods(mods).to_html }

    context 'with xml entities' do
      let(:mods) do
        <<-XML
          <mods xmlns=\"http://www.loc.gov/mods/v3\">
            <abstract>&gt;i:&lt;</abstract>
          </mods>
        XML
      end

      it 'passes xml entities through' do
        expect(html).to match(%r{<dd>&gt;i:&lt;</dd>})
      end
    end

    context 'with cdata-wrapped XML' do
      let(:mods) do
        <<-XML
          <mods xmlns=\"http://www.loc.gov/mods/v3\">
            <abstract><![CDATA[<i>]]>Some title<![CDATA[</i>]]> in an abstract</abstract>
          </mods>
        XML
      end

      it 'passes xml entities through' do
        expect(html).to match(%r{<dd><i>Some title</i> in an abstract</dd>})
      end
    end

    context 'with consecutive new line characters' do
      let(:mods) do
        <<-XML
          <mods xmlns=\"http://www.loc.gov/mods/v3\">
            <abstract>blah\n\nblah</abstract>
          </mods>
        XML
      end

      it 'passes xml entities through' do
        expect(html).to match(%r{<dd><p>blah</p>\n\n<p>blah</p></dd>})
      end
    end
  end
end
