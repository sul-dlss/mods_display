# frozen_string_literal: true

def mods_display_note(mods_record)
  ModsDisplay::Note.new(mods_record)
end

describe ModsDisplay::Note do
  before(:all) do
    @note = Stanford::Mods::Record.new.from_str('<mods xmlns="http://www.loc.gov/mods/v3"><note>Note Field</note></mods>').note
    @display_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><note displayLabel='Special Label'>Note Field</note></mods>"
    ).note
    @sor_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><note type='statement of responsibility'>Note Field</note></mods>"
    ).note
    @contact_note = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><note type='contact'>jdoe@example.com</note><note>Note Field</note></mods>"
    ).note
    @type_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\"><note type='some other Type'>Note Field</note></mods>"
    ).note
    @complex_label = Stanford::Mods::Record.new.from_str(
      "<mods xmlns=\"http://www.loc.gov/mods/v3\">
        <note>Note Field</note><note>2nd Note Field</note>
        <note type='statement of responsibility'>SoR</note>
        <note>Another Note</note>
      </mods>"
    ).note
  end

  describe 'label' do
    it 'has a default label' do
      expect(mods_display_note(@note).fields.first.label).to eq('Note:')
    end

    it 'uses the displayLabel attribute when one is available' do
      expect(mods_display_note(@display_label).fields.first.label).to eq('Special Label:')
    end

    it 'uses get a label from a list of translations' do
      expect(mods_display_note(@sor_label).fields.first.label).to eq('Statement of responsibility:')
    end

    it 'uses use the capitalized type attribute if one is present' do
      expect(mods_display_note(@type_label).fields.first.label).to eq('Some other type:')
    end
  end

  describe 'fields' do
    it 'handles single values' do
      fields = mods_display_note(@note).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['Note Field'])
    end

    it 'handles complex grouping' do
      fields = mods_display_note(@complex_label).fields
      expect(fields.length).to eq(3)
      expect(fields.first.label).to eq('Note:')
      expect(fields.first.values.length).to eq 2
      expect(fields.first.values).to eq(['Note Field', '2nd Note Field'])

      expect(fields[1].label).to eq 'Statement of responsibility:'
      expect(fields[1].values.length).to eq 1
      expect(fields[1].values).to eq(['SoR'])

      expect(fields.last.label).to eq('Note:')
      expect(fields.last.values.length).to eq 1
      expect(fields.last.values).to eq(['Another Note'])
    end

    it 'does not include any contact fields' do
      fields = mods_display_note(@contact_note).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['Note Field'])
    end
  end
end
