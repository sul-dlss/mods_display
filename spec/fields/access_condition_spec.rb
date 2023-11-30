# frozen_string_literal: true

describe ModsDisplay::AccessCondition do
  include AccessConditionFixtures

  let(:fields) { described_class.new(access_condition).fields }

  let(:access_condition) { Stanford::Mods::Record.new.from_str(mods).accessCondition }

  describe 'labels' do
    let(:mods) { restricted_access_fixture }

    it 'normalizes types and assign proper labels' do
      expect(fields.length).to eq(1)
      expect(fields.first.label).to eq('Restriction on access:')
      fields.first.values.each_with_index do |value, index|
        expect(value).to match(/^Restrict Access Note#{index + 1}/)
      end
    end
  end

  describe 'fields' do
    describe 'copyright' do
      let(:mods) { copyright_access_fixture }

      it "replaces instances of '(c) copyright' with the HTML copyright entity" do
        expect(fields.length).to eq(1)
        expect(fields.first.values.length).to eq(1)
        expect(fields.first.values.first).to eq(
          'This is a &copy; Note.  Single instances of &copy; should also be replaced in these notes.'
        )
      end
    end

    describe 'licenses' do
      context 'when the license is a legacy CreativeCommons license' do
        let(:mods) { legacy_cc_license_fixture }

        it 'identifies and link legacy CreativeCommons licenses properly' do
          expect(fields.length).to eq(1)
          expect(fields.first.values.length).to eq(1)
          expect(fields.first.values.first).to include("<a href='http://creativecommons.org/licenses/by-sa/3.0/'>")
          expect(fields.first.values.first).to include(
            'This work is licensed under a Creative Commons Attribution-Share Alike 3.0 Unported License'
          )
        end
      end

      context 'when the license is a CreativeCommons license' do
        let(:mods) { cc_license_fixture }

        it 'identifies and link CreativeCommons licenses properly' do
          expect(fields.length).to eq(1)
          expect(fields.first.values.length).to eq(1)
          expect(fields.first.values.first).to include(
            "This work is licensed under a <a href='https://creativecommons.org/licenses/by/3.0/legalcode'>Creative Commons Attribution 3.0 Unported license (CC BY)</a>."
          )
        end
      end

      context 'when the license is an OpenDataCommons license' do
        let(:mods) { odc_license_fixture }

        it 'identifies and link OpenDataCommons licenses properly' do
          expect(fields.length).to eq(1)
          expect(fields.first.values.length).to eq(1)
          expect(fields.first.values.first).to include("<a href='http://opendatacommons.org/licenses/pddl/'>")
          expect(fields.first.values.first).to include(
            'This work is licensed under a Open Data Commons Public Domain Dedication and License (PDDL)'
          )
        end
      end

      context 'when the license is not a known license' do
        let(:mods) { no_license_fixture }

        it 'does not attempt unknown license types' do
          expect(fields.length).to eq(1)
          expect(fields.first.values.length).to eq(1)
          expect(fields.first.values.first).to include(
            'This work is licensed under an Unknown License and will not be linked'
          )
          expect(fields.first.values.first).not_to include('<a.*>')
        end
      end

      context 'when the license does not look like our expected format' do
        let(:mods) { garbage_license_fixture }

        it 'returns the license text' do
          expect(fields.length).to eq(1)
          expect(fields.first.values.length).to eq(1)
          expect(fields.first.values.first).to include(
            'Unknown garbage that does not look like a license'
          )
          expect(fields.first.values.first).not_to include('<a.*>')
        end
      end
    end

    describe 'use and reproduction' do
      let(:mods) { custom_use_reproduction_fixture }

      it 'preserves newlines' do
        expect(fields.length).to eq(1)
        expect(fields.first.values).to eq ["Special use agreement\n\nText of the agreement"]
      end
    end
  end
end
