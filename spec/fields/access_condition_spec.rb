# frozen_string_literal: true

require 'spec_helper'

def mods_display_access_condition(mods_record)
  ModsDisplay::AccessCondition.new(
    mods_record
  )
end

describe ModsDisplay::AccessCondition do
  include AccessConditionFixtures
  before :all do
    @access_condition = Stanford::Mods::Record.new.from_str(simple_access_condition_fixture).accessCondition
    @restrict_condition = Stanford::Mods::Record.new.from_str(restricted_access_fixture).accessCondition
    @custom_use_reproduction = Stanford::Mods::Record.new.from_str(custom_use_reproduction_fixture).accessCondition
    @copyright_note = Stanford::Mods::Record.new.from_str(copyright_access_fixture).accessCondition
    @cc_license_note = Stanford::Mods::Record.new.from_str(cc_license_fixture).accessCondition
    @odc_license_note = Stanford::Mods::Record.new.from_str(odc_license_fixture).accessCondition
    @no_link_license_note = Stanford::Mods::Record.new.from_str(no_license_fixture).accessCondition
    @garbage_license_fixture = Stanford::Mods::Record.new.from_str(garbage_license_fixture).accessCondition
  end

  describe 'labels' do
    it 'normalizes types and assign proper labels' do
      fields = mods_display_access_condition(@restrict_condition).fields
      expect(fields.length).to eq(1)
      expect(fields.first.label).to eq('Restriction on access:')
      fields.first.values.each_with_index do |value, index|
        expect(value).to match(/^Restrict Access Note#{index + 1}/)
      end
    end
  end

  describe 'fields' do
    describe 'copyright' do
      it "replaces instances of '(c) copyright' with the HTML copyright entity" do
        fields = mods_display_access_condition(@copyright_note).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first).to eq(
          'This is a &copy; Note.  Single instances of &copy; should also be replaced in these notes.'
        )
      end
    end

    describe 'licenses' do
      it 'identifies and link CreativeCommons licenses properly' do
        fields = mods_display_access_condition(@cc_license_note).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first).to include("<a href='http://creativecommons.org/licenses/by-sa/3.0/'>")
        expect(fields.first.values.first).to include(
          'This work is licensed under a Creative Commons Attribution-Share Alike 3.0 Unported License'
        )
      end

      it 'identifies and link OpenDataCommons licenses properly' do
        fields = mods_display_access_condition(@odc_license_note).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first).to include("<a href='http://opendatacommons.org/licenses/pddl/'>")
        expect(fields.first.values.first).to include(
          'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
        )
      end

      it 'does not attempt unknown license types' do
        fields = mods_display_access_condition(@no_link_license_note).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first).to include(
          'This work is licensed under an Unknown License and will not be linked'
        )
        expect(fields.first.values.first).not_to include('<a.*>')
      end

      it 'returns the license text if it does not look like our expected format' do
        fields = mods_display_access_condition(@garbage_license_fixture).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first).to include(
          'Unknown garbage that does not look like a license'
        )
        expect(fields.first.values.first).not_to include('<a.*>')
      end
    end

    describe 'use and reproduction' do
      it 'preserves newlines' do
        fields = mods_display_access_condition(@custom_use_reproduction).fields
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq ["Special use agreement\n\nText of the agreement"]
      end
    end
  end
end
