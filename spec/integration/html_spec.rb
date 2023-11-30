# frozen_string_literal: true

def html_from_mods(xml, locale = nil)
  I18n.locale = locale if locale
  I18n.fallbacks[:fr] = %i[fr en]
  ModsDisplay::Record.new(xml).mods_display_html
end

RSpec.describe 'HTML Output' do
  after(:all) do
    I18n.locale = :en
  end

  describe 'i18n' do
    subject(:html) { instance.to_html }

    let(:instance) { html_from_mods(mods) }
    let(:mods) do
      <<~XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <titleInfo><title>Main Title</title></titleInfo>
          <abstract>Hey. I'm an abstract.</abstract>
        </mods>
      XML
    end

    it 'gets the default english translations' do
      expect(html).to match(%r{<dt>Title</dt>})
    end

    context 'with french' do
      let(:instance) { html_from_mods(mods, :fr) }

      it 'internationalizes the labels when translations are available' do
        expect(html).to match(%r{<dt>Résumé </dt>})
      end

      it 'gets fallback to the default english translations if a translation is missing' do
        expect(html).to match(%r{<dt>Title</dt>})
      end
    end
  end

  describe '#title' do
    context 'with alternative titles' do
      let(:instance) do
        html_from_mods(
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
      end

      it 'returns just the first title in the #title method' do
        expect(instance.title).to eq(['Main Title'])
      end
    end
  end

  describe '#body' do
    subject(:body) { instance.body }

    context 'with alternative titles' do
      let(:instance) do
        html_from_mods(
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
      end

      it 'omits the first title and return any remaining titles in the #body' do
        expect(body).not_to match(%r{<dd>\s*Main Title\s*</dd>})
        expect(body).to match(%r{<dd>\s*Alternate Title<br />Second Alternate Title\s*</dd>})
      end
    end
  end

  describe '#subTitle' do
    subject(:sub_title) { instance.subTitle }

    context 'with alternative titles' do
      let(:instance) do
        html_from_mods(
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
      end

      it 'allows access to the subTitle independently from the title (for use with #body or fields)' do
        expect(sub_title.length).to eq 1
        expect(sub_title.first).to be_a ModsDisplay::Values
        expect(sub_title.first.label).to match(/^Alternative title/i)
        expect(sub_title.first.values).to eq(['Alternate Title', 'Second Alternate Title'])
      end
    end
  end

  describe '#abstract' do
    let(:instance) do
      html_from_mods("<mods xmlns=\"http://www.loc.gov/mods/v3\"><abstract>Hey. I'm an abstract.</abstract></mods>")
    end

    context 'with no arguments' do
      subject(:abstract) { instance.abstract }

      it 'returns ModsDisplay::Values' do
        abstract.each do |field|
          expect(field).to be_a ModsDisplay::Values
        end
        expect(abstract.length).to eq 1
        expect(abstract.first.values).to eq ["Hey. I'm an abstract."]
      end
    end

    context 'when raw is specified' do
      subject(:abstract) { instance.abstract(raw: true) }

      it { is_expected.to be_a ModsDisplay::Abstract }
    end
  end

  describe '#genre' do
    subject(:genre) { instance.genre }

    let(:instance) do
      html_from_mods('<mods xmlns="http://www.loc.gov/mods/v3"></mods>')
    end

    context 'when no data is available' do
      it 'returns a blank array if no data is available for a specific field' do
        expect(genre).to eq []
      end
    end
  end

  describe '#to_html' do
    subject(:html) { html_from_mods(mods).to_html }

    context 'with xml entities' do
      let(:mods) do
        <<-XML
          <mods xmlns="http://www.loc.gov/mods/v3">
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
          <mods xmlns="http://www.loc.gov/mods/v3">
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
          <mods xmlns="http://www.loc.gov/mods/v3">
            <abstract>blah\n\nblah</abstract>
          </mods>
        XML
      end

      it 'passes xml entities through' do
        expect(html).to match(%r{<dd><p>blah</p>\n\n<p>blah</p></dd>})
      end
    end

    context 'with multiple titles' do
      let(:mods) do
        <<-XML
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
        XML
      end

      it 'includes all titles it regular display' do
        expect(html).to match(%r{<dd>\s*Main Title\s*</dd>})
        expect(html).to match(%r{<dd>\s*Alternate Title<br />Second Alternate Title\s*</dd>})
      end
    end
  end
end
