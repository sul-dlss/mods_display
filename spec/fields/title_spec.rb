# frozen_string_literal: true

def mods_display_title(mods_record)
  ModsDisplay::Title.new(mods_record)
end

describe ModsDisplay::Title do
  include TitleFixtures
  before(:all) do
    @title = Stanford::Mods::Record.new.from_str(simple_title_fixture).title_info
    @title_parts = Stanford::Mods::Record.new.from_str(title_parts_fixture).title_info
    @reverse_title_parts = Stanford::Mods::Record.new.from_str(reverse_title_parts_fixture).title_info
    @display_label = Stanford::Mods::Record.new.from_str(display_label_fixture).title_info
    @multi_label = Stanford::Mods::Record.new.from_str(multi_label_fixture).title_info
    @alt_title = Stanford::Mods::Record.new.from_str(alt_title_fixture).title_info
    @title_punctuation = Stanford::Mods::Record.new.from_str(title_puncutation_fixture).title_info
    @ordered_title_fixture = Stanford::Mods::Record.new.from_str(ordered_title_fixture).title_info
  end

  describe 'labels' do
    it 'returns a default label of Title if nothing else is available' do
      expect(mods_display_title(@title).fields.first.label).to eq('Title:')
    end

    it 'returns an appropriate label from the type attribute' do
      expect(mods_display_title(@alt_title).fields.first.label).to eq('Alternative title:')
    end

    it 'returns the label held in the displayLabel attribute of the titleInfo element when available' do
      expect(mods_display_title(@display_label).fields.first.label).to eq('MyTitle:')
    end

    it 'collapses adjacent identical labels' do
      fields = mods_display_title(@multi_label).fields
      expect(fields.length).to eq(4)
      expect(fields[0].label).to eq('Title:')
      expect(fields[1].label).to eq('Alternative title:')
      expect(fields[2].label).to eq('Uniform title:')
      expect(fields[3].label).to eq('Alternative title:')
      expect(fields[3].values).to eq(['Another Alt Title', 'Yet Another Alt Title'])
    end
  end

  describe 'fields' do
    it 'returns an array of label/value objects' do
      values = mods_display_title(@display_label).fields
      expect(values.length).to eq(1)
      expect(values.first).to be_a ModsDisplay::Values
      expect(values.first.label).to eq('MyTitle:')
      expect(values.first.values).to eq(['Title'])
    end
  end

  describe 'text' do
    it 'constructs all the elements in titleInfo' do
      expect(mods_display_title(@title_parts).fields.first.values).to include 'The Title : For. Something. Part 62'
    end

    it 'uses the correct delimiter in the case that a partNumber comes before a partName' do
      expect(mods_display_title(@reverse_title_parts).fields.first.values).to include(
        'The Title : For. Part 62, Something'
      )
    end

    it 'returns the basic text held in a sub element of titleInfo' do
      expect(mods_display_title(@title).fields.first.values).to include 'Title'
    end

    it 'does not duplicate delimiter punctuation' do
      values = mods_display_title(@title_punctuation).fields.first.values
      expect(values.length).to eq 1
      expect(values.first).not_to include '..'
      expect(values.first).to eq 'A title that ends in punctuation. 2015'
    end

    it 'combines the title parts in the order from the record' do
      values = mods_display_title(@ordered_title_fixture).fields.first.values
      expect(values.length).to eq 1

      expect(values.first).to eq 'The medium term expenditure framework (MTEF) for ... and the annual estimates for ... 016, Ministry of Tourism : expenditure to be met out of moneys granted and drawn from the consolidated fund, central government budget'
    end

    it 'does not add space after a non-sorting part that ends in a hyphen or apostrophe' do
      data = <<-XML
        <mods xmlns="http://www.loc.gov/mods/v3">
          <titleInfo>
           <nonSort>L'</nonSort>
           <title>Afrique dressée selon les derniers relations et suivant les nouvelles decouvertes dont les points principaux sont placez sur les observations de Messieurs de l'Academie Royal des Sciences</title>
          </titleInfo>
        </mods>
      XML

      values = mods_display_title(Stanford::Mods::Record.new.from_str(data).title_info).fields.first.values

      expect(values.first).to start_with "L'Afrique dressée"
    end
  end

  describe 'uniform titles' do
    let(:xml) do
      Stanford::Mods::Record.new.from_str(<<-XML).title_info
        <mods xmlns="http://www.loc.gov/mods/v3">
          <titleInfo type="uniform" nameTitleGroup="1">
            <title>Motets</title>
            <partNumber>(1583)</partNumber>
          </titleInfo>
          <name type="personal" nameTitleGroup="1" usage="primary">
            <namePart>Palestrina, Giovanni Pierluigi da</namePart>
            <namePart type="date">1525?-1594</namePart>
          </name>
        </mods>
      XML
    end

    it 'prepends the uniform author name' do
      values = mods_display_title(xml).fields.first.values

      expect(values.first).to eq 'Palestrina, Giovanni Pierluigi da, 1525?-1594. Motets. (1583)'
    end
  end
end
