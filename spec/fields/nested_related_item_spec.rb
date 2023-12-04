# frozen_string_literal: true

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
      before do
        allow(ModsDisplay::NestedRelatedItem::ValueRenderer).to receive(:new).and_call_original
      end

      it 'only calls related_item_mods_object once per item regardless of how many times the method is called' do
        expect(ModsDisplay::NestedRelatedItem::ValueRenderer).to receive(:new).twice

        5.times { nested_related_item.fields }
      end
    end

    context 'when a value renderer is provided' do
      let(:fields) { nested_related_item.fields }
      let(:nested_related_item) do
        described_class.new(
          Stanford::Mods::Record.new.from_str(mods).related_item,
          value_renderer: value_renderer
        )
      end

      # rubocop:disable RSpec/VerifiedDoubles
      let(:value_renderer) { double('ValueRenderer', new: value_renderer_instance) }
      let(:value_renderer_instance) { double('ValueRendererInstance') }
      # rubocop:enable RSpec/VerifiedDoubles

      before do
        allow(value_renderer_instance).to receive(:render).and_return('rendered value1', 'rendered value2')
      end

      it 'calls the value renderer to get Values values' do
        expect(value_renderer).to receive(:new).twice

        expect(fields.first.values).to eq ['rendered value1', 'rendered value2']
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

    describe 'with a namespace prefix' do
      let(:mods) { namespace_prefixed_related_item_fixture }

      it 'renders the list' do
        within(html.first('dd')) do |dd|
          expect(dd).to have_css('ul.mods_display_nested_related_items')
          within(dd.find('ul.mods_display_nested_related_items li')) do |li|
            expect(li).to have_css('dl dt', text: 'Constituent Title:')
            expect(li).to have_css('dl dd', text: 'Constituent note')
          end
        end
      end
    end
  end
end
