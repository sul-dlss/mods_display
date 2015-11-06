require 'spec_helper'
require 'fixtures/subjects_fixtures'
include SubjectsFixtures

def mods_display_subject(mods_record)
  config = ModsDisplay::Configuration::Subject.new do
    link :link_method, '%value%'
  end
  ModsDisplay::Subject.new(mods_record, config, TestController.new)
end

def mods_display_hierarchical_subject(mods_record)
  config = ModsDisplay::Configuration::Subject.new do
    hierarchical_link true
    link :link_method, '%value%'
  end
  ModsDisplay::Subject.new(mods_record, config, TestController.new)
end

describe ModsDisplay::Subject do
  before(:all) do
    @subject = Stanford::Mods::Record.new.from_str(subjects, false).subject
    @blank_subject = Stanford::Mods::Record.new.from_str(blank_subject, false).subject
    @emdash_subject = Stanford::Mods::Record.new.from_str(emdash_subjects, false).subject
    @geo_subject = Stanford::Mods::Record.new.from_str(hierarchical_geo_subjects, false).subject
    @name_subject = Stanford::Mods::Record.new.from_str(name_subjects, false).subject
    @blank_name_subject = Stanford::Mods::Record.new.from_str(blank_name_subject, false).subject
    @complex_subject = Stanford::Mods::Record.new.from_str(complex_subjects, false).subject
    @display_label = Stanford::Mods::Record.new.from_str(display_label_subjects, false).subject
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
      expect(fields.first.values.first.first.roles).to eq(['Depicted'])
    end
    it 'should link the name (and not the role) correctly' do
      html = mods_display_subject(@name_subject).to_html
      expect(html).to match(%r{<a href='.*\?John Doe'>John Doe</a> \(Depicted\)})
      expect(html).to match(%r{<a href='.*\?Anonymous People'>Anonymous People</a>})
    end
    it 'should linke the name (and not the role) correctly when linking hierarchicaly' do
      html = mods_display_hierarchical_subject(@name_subject).to_html
      expect(html).to match(%r{<a href='.*\?John Doe'>John Doe</a> \(Depicted\)})
      expect(html).to match(%r{<a href='.*\?John Doe Anonymous People'>Anonymous People</a>})
    end
  end

  describe 'to_html' do
    it 'should link the values when requested' do
      html = mods_display_subject(@subject).to_html
      expect(html).to match(%r{<a href='http://library.stanford.edu\?Jazz'>Jazz</a>})
      expect(html).to match(%r{<a href='http://library.stanford.edu\?Japan'>Japan</a>})
      expect(html).to match(%r{<a href='http://library.stanford.edu\?History and criticism'>History and criticism</a>})
    end
    it 'does something' do
      html = mods_display_hierarchical_subject(@subject).to_html
      expect(html).to match(%r{<a href='http://library.stanford.edu\?Jazz'>Jazz</a>})
      expect(html).to match(%r{<a href='http://library.stanford.edu\?Jazz Japan'>Japan</a>})
      expect(html).to match(
        %r{<a href='http://library.stanford.edu\?Jazz Japan History and criticism'>History and criticism</a>}
      )
    end
    it 'should collapse fields into the same label' do
      html = mods_display_subject(@complex_subject).to_html
      expect(html.scan(%r{<dt title='Subject'>Subject:</dt>}).length).to eq(1)
      expect(html.scan(/<dd>/).length).to eq(1)
      expect(html.scan(%r{<br/>}).length).to eq(1)
      expect(html.scan(/ &gt; /).length).to eq(3)
    end
    it 'should handle complex display labels' do
      html = mods_display_subject(@display_label).to_html
      expect(html.scan(%r{<dt title='Subject'>Subject:</dt>}).length).to eq 2
      expect(html.scan(%r{<dt title='Subject Heading'>Subject Heading:</dt>}).length).to eq 1
      expect(html.scan(/<dd>/).length).to eq(3)
    end
  end
end
