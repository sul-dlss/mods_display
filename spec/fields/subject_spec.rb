require 'spec_helper'
require 'fixtures/subjects_fixtures'
include SubjectsFixtures

def mods_display_subject(mods_record)
  ModsDisplay::Subject.new(mods_record)
end

describe ModsDisplay::Subject do
  before(:all) do
    @subject = Stanford::Mods::Record.new.from_str(subjects).subject
    @blank_subject = Stanford::Mods::Record.new.from_str(blank_subject).subject
    @emdash_subject = Stanford::Mods::Record.new.from_str(emdash_subjects).subject
    @geo_subject = Stanford::Mods::Record.new.from_str(hierarchical_geo_subjects).subject
    @name_subject = Stanford::Mods::Record.new.from_str(name_subjects).subject
    @blank_name_subject = Stanford::Mods::Record.new.from_str(blank_name_subject).subject
    @complex_subject = Stanford::Mods::Record.new.from_str(complex_subjects).subject
    @display_label = Stanford::Mods::Record.new.from_str(display_label_subjects).subject
  end
  describe 'fields' do
    it 'should split individual child elments of subject into separate parts' do
      fields = mods_display_subject(@subject).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq([['Jazz', 'Japan', 'History and criticism']])
    end
    it 'should split horizontalized subjects split with an emdash into separate parts' do
      fields = mods_display_subject(@emdash_subject).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq([['Jazz', 'Japan', 'History and criticism']])
    end
    it 'should handle hierarchicalGeogaphic subjects properly' do
      fields = mods_display_subject(@geo_subject).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq([['United States', 'California', 'Stanford']])
    end
    it 'should handle display labels properly' do
      fields = mods_display_subject(@display_label).fields
      expect(fields.length).to eq(3)
      expect(fields.first.label).to eq('Subject:')
      expect(fields.first.values).to eq([['A Subject', 'Another Subject'], ['B Subject', 'Another B Subject']])
      expect(fields[1].label).to eq('Subject Heading:')
      expect(fields[1].values).to eq([['Jazz', 'Japan', 'History and criticism']])
      expect(fields.last.label).to eq('Subject:')
      expect(fields.last.values).to eq([['Bay Area', 'Stanford']])
    end
    it 'should handle blank subjects properly' do
      expect(mods_display_subject(@blank_subject).fields).to eq([])
    end
    it 'should handle blank name subjects properly' do
      expect(mods_display_subject(@blank_name_subject).fields).to eq([])
    end
  end

  describe 'name subjects' do
    it 'should handle name subjects properly' do
      fields = mods_display_subject(@name_subject).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values.first.first).to be_a(ModsDisplay::Name::Person)
      expect(fields.first.values.first.first.name).to eq('John Doe')
    end
  end

  describe 'to_html' do
    it 'should collapse fields into the same label' do
      html = mods_display_subject(@complex_subject).to_html
      expect(html.scan(%r{<dt>Subject</dt>}).length).to eq(1)
      expect(html.scan(/<dd>/).length).to eq(1)
      expect(html.scan(%r{<br />}).length).to eq(1)
      expect(html.scan(/ &gt; /).length).to eq(3)
    end
    it 'should handle complex display labels' do
      html = mods_display_subject(@display_label).to_html
      expect(html.scan(%r{<dt>Subject</dt>}).length).to eq 2
      expect(html.scan(%r{<dt>Subject Heading</dt>}).length).to eq 1
      expect(html.scan(/<dd>/).length).to eq(3)
    end
  end
end
