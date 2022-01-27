# frozen_string_literal: true

require 'spec_helper'

describe ModsDisplay::NestedRelatedItem do
  include RelatedItemFixtures
  include NestedRelatedItemFixtures

  let(:nested_related_item) do
    described_class.new(
      Stanford::Mods::Record.new.from_str(mods).related_item
    )
  end

  describe '#label' do
    subject(:label) { nested_related_item.fields.first.label }

    context 'when a constituent' do
      let(:mods) { multi_constituent_fixture }

      it { is_expected.to eq 'Contains:' }
    end

    context 'when a host' do
      let(:mods) { related_item_host_fixture }

      it { is_expected.to eq 'Appears in:' }
    end
  end

  describe '#fields' do
    subject(:fields) { nested_related_item.fields }

    let(:mods) { multi_constituent_fixture }

    describe 'memoization' do
      it 'only calls related_item_mods_object once per item regardless of how many times the method is called' do
        expect(nested_related_item).to receive(:related_item_mods_object).twice

        5.times { nested_related_item.fields }
      end
    end

    context 'when an element that should be nested' do
      it 'has a field for each related item' do
        expect(fields.length).to eq 1
      end
    end

    context 'when a collection' do
      let(:mods) { related_item_host_fixture }

      it 'is not included' do
        expect(fields.length).to eq 1 # This fixture has two host related items one of which is a collection
        expect(fields.first.values.to_s).not_to include 'A collection'
      end
    end

    context 'when handled by another related_item class' do
      let(:mods) { basic_related_item_fixture }

      it { is_expected.to be_empty }
    end
  end

  describe '#to_html' do
    subject(:html) { Capybara.string(nested_related_item.to_html) }

    let(:mods) { related_item_host_fixture }

    it 'renders an unordered list with an embedded dl containing the metadata of the related item' do
      within(html.first('dd')) do |dd|
        expect(dd).to have_css('ul.mods_display_nested_related_items')
        within(dd.find('ul.mods_display_nested_related_items li')) do |li|
          expect(li).to have_css('dl dt', text: 'Custom Notes:')
          expect(li).to have_css('dl dd', text: 'A note content')
        end
      end
    end
  end
end
