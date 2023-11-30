# frozen_string_literal: true

require 'fixtures/name_fixtures'
include NameFixtures

def mods_display_name(mods_record)
  ModsDisplay::Name.new(mods_record)
end

describe ModsDisplay::Name do
  include NameFixtures
  before(:all) do
    @name = Stanford::Mods::Record.new.from_str(simple_name_fixture).plain_name
    @blank_name = Stanford::Mods::Record.new.from_str(blank_name_fixture).plain_name
    @primary_name = Stanford::Mods::Record.new.from_str(primary_name_fixture).plain_name
    @primary_name_solo = Stanford::Mods::Record.new.from_str(primary_name_solo_fixture).plain_name
    @contributor = Stanford::Mods::Record.new.from_str(contributor_fixture).plain_name
    @encoded_role = Stanford::Mods::Record.new.from_str(encoded_role_fixture).plain_name
    @mixed_role = Stanford::Mods::Record.new.from_str(mixed_role_fixture).plain_name
    @numeral_toa = Stanford::Mods::Record.new.from_str(numural_toa_fixture).plain_name
    @simple_toa = Stanford::Mods::Record.new.from_str(simple_toa_fixture).plain_name
    @display_form = Stanford::Mods::Record.new.from_str(display_form_name_fixture).plain_name
    @collapse_label = Stanford::Mods::Record.new.from_str(collapse_label_name_fixture).plain_name
    @complex_labels = Stanford::Mods::Record.new.from_str(complex_name_label_fixture).plain_name
    @complex_roles = Stanford::Mods::Record.new.from_str(complex_role_name_fixture).plain_name
    @name_with_role = Stanford::Mods::Record.new.from_str(name_with_role_fixture).plain_name
    @multiple_roles = Stanford::Mods::Record.new.from_str(multiple_roles_fixture).plain_name
    @author_role = Stanford::Mods::Record.new.from_str(author_role_fixture).plain_name
    @many_roles_and_names = Stanford::Mods::Record.new.from_str(many_roles_and_names_fixture).plain_name
    @names_with_code_and_text_roles = Stanford::Mods::Record.new.from_str(names_with_code_and_text_roles_fixture).plain_name
    @name_with_identifiers = Stanford::Mods::Record.new.from_str(name_with_identifiers).plain_name
  end

  let(:default_label) { 'Associated with:' }

  describe 'label' do
    it 'defaults Author/Creator when no role is available' do
      expect(mods_display_name(@name).fields.first.label).to eq(default_label)
    end

    it 'labels as role for primary authors with a role' do
      expect(mods_display_name(@primary_name).fields.first.label).to eq('Lithographer:')
    end

    it "labels 'Author/Creator' for non-role primary authors" do
      expect(mods_display_name(@primary_name_solo).fields.first.label).to eq(default_label)
    end

    it 'applies role labeling with text' do
      expect(mods_display_name(@contributor).fields.first.label).to eq('Lithographer:')
    end

    it 'applies role labeling with code' do
      expect(mods_display_name(@author_role).fields.first.label).to eq('Author:')
    end

    it 'strips trailing punctuation' do
      actual = mods_display_name(Stanford::Mods::Record.new.from_str(name_with_marc_role_terms).plain_name)

      expect(actual.fields.map(&:label)).to eq ['Editor:', 'Publisher:']
    end
  end

  describe 'fields' do
    it 'uses the display form when available' do
      fields = mods_display_name(@display_form).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values.length).to eq(1)
      expect(fields.first.values.first).to be_a(ModsDisplay::Name::Person)
      expect(fields.first.values.first.name).to eq('Mr. John Doe')
    end

    it 'decodes XML entities' do
      fields = mods_display_name(Stanford::Mods::Record.new.from_str(entities_name_fixture).plain_name).fields
      expect(fields.first.values.first.name).to eq('J. & C. Walker')
    end

    it 'does not add blank names' do
      expect(mods_display_name(@blank_name).fields).to eq([])
    end

    it 'does not delimit given name and termsOfAddress (that begin w/ roman numerals) with a comma' do
      fields = mods_display_name(@numeral_toa).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values.length).to eq(1)
      expect(fields.first.values.first.to_s).not_to match(/Given Name, XVII/)
      expect(fields.first.values.first.to_s).to match(/Given Name XVII/)
    end

    it 'delimits given name and termsOfAddress (that DO NOT begin w/ roman numerals) with a comma' do
      fields = mods_display_name(@simple_toa).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values.length).to eq(1)
      expect(fields.first.values.first.to_s).to match(/Given Name, Ier, empereur/)
      expect(fields.first.values.first.to_s).not_to match(/Given Name Ier, empereur/)
    end

    it 'collapses adjacent matching labels' do
      fields = mods_display_name(@collapse_label).fields
      expect(fields.length).to eq(1)
      expect(fields.first.label).to eq(default_label)
      # rubocop:disable Style/HashEachMethods
      fields.first.values.each do |val|
        expect(['John Doe', 'Jane Doe']).to include val.to_s
      end
      # rubocop:enable Style/HashEachMethods
    end

    it 'preserves order and separation of non-adjesent matching labels' do
      fields = mods_display_name(@complex_labels).fields

      expect(fields.length).to eq(2)
      expect(fields.first.label).to eq(default_label)
      expect(fields.first.values.length).to eq(3)
      expect(fields.first.values.map(&:to_s)).to include 'John Doe', 'Jane Dough', 'John Dough'

      expect(fields[1].label).to eq('Lithographer:')
      expect(fields[1].values.length).to eq(1)
      expect(fields[1].values.first.name).to eq('Jane Doe')
    end

    describe 'roles' do
      it 'gets the role when present' do
        fields = mods_display_name(@name_with_role).fields
        expect(fields.length).to eq(1)
        expect(fields.first.label).to eq('Depicted:')
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first).to be_a(ModsDisplay::Name::Person)
      end

      it 'decodes encoded roleTerms when no text (or non-typed) roleTerm is available' do
        fields = mods_display_name(@encoded_role).fields
        expect(fields.length).to eq(1)
        expect(fields.first.label).to eq('Lithographer:')
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first.to_s).to eq('John Doe')
      end

      it "gets the type='text' role before an untyped role" do
        fields = mods_display_name(@mixed_role).fields
        expect(fields.length).to eq(2)
        expect(fields.first.label).to eq 'Publisher:'
        expect(fields.last.label).to eq 'Engraver:'
        expect(fields.first.values.length).to eq(1)
        expect(fields.last.values.length).to eq(1)
        expect(fields.first.values.first.name).to eq fields.last.values.first.name
      end

      it 'is handled correctly when there are more than one' do
        fields = mods_display_name(@multiple_roles).fields
        expect(fields.length).to eq 2
        expect(fields.first.label).to eq 'Depicted:'
        expect(fields.last.label).to eq 'Artist:'
        expect(fields.first.values.length).to eq(1)
        expect(fields.last.values.length).to eq(1)
        expect(fields.first.values.first.name).to eq fields.last.values.first.name
      end

      it 'prefers to use the coded roleTerm when generating labels' do
        fields = mods_display_name(@complex_roles).fields
        expect(fields.map(&:label)).to eq ['Depositor:']
        expect(fields.first.values.first.name).to eq fields.last.values.first.name
      end

      it 'handles consolidation of many roles and names' do
        fields = mods_display_name(@many_roles_and_names).fields
        expect(fields.length).to eq 6
        expect(fields.map(&:label)).to eq ['Associated with:', 'Surveyor:', 'Cartographer:', 'Editor:',
                                           'Electrotyper:', 'Lithographer:']
      end

      it 'handles consolidation of names with both code and text roleTerms' do
        fields = mods_display_name(@names_with_code_and_text_roles).fields
        expect(fields.length).to eq 3
        expect(fields.map(&:label)).to eq %w[Author: Printer: Donor:]
      end
    end
  end

  describe 'to_html' do
    it 'adds the role to the name in parens' do
      html = mods_display_name(@name_with_role).to_html
      expect(html).to match(%r{<dd>John Doe</dd>})
    end
  end

  describe 'orcid' do
    it 'returns the orcid value if there is one' do
      person_name = mods_display_name(@name_with_identifiers).fields.first.values.first
      expect(person_name).to be_a(ModsDisplay::Name::Person)
      expect(person_name.orcid).to eq('0000-0002-6666-7777')
    end

    it 'returns nil if no orcid' do
      person_name = mods_display_name(@name).fields.first.values.first
      expect(person_name).to be_a(ModsDisplay::Name::Person)
      expect(person_name.orcid).to be_nil
    end
  end
end
