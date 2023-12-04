# frozen_string_literal: true

def mods_display_item(mods_record)
  ModsDisplay::RelatedItem.new(mods_record)
end

describe ModsDisplay::RelatedItem do
  include RelatedItemFixtures
  include NestedRelatedItemFixtures

  before(:all) do
    @item = Stanford::Mods::Record.new.from_str(basic_related_item_fixture).related_item
    @linked_item = Stanford::Mods::Record.new.from_str(linked_related_item_fixture).related_item
    @collection = Stanford::Mods::Record.new.from_str(related_item_collection_fixture).related_item
    @display_label = Stanford::Mods::Record.new.from_str(related_item_display_label_fixture).related_item
    @location = Stanford::Mods::Record.new.from_str(related_item_location_fixture).related_item
    @reference = Stanford::Mods::Record.new.from_str(related_item_reference_fixture).related_item
    @blank_item = Stanford::Mods::Record.new.from_str(blank_related_item_fixture).related_item
    @multi_items = Stanford::Mods::Record.new.from_str(multi_related_item_fixture).related_item
    @constituent_items = Stanford::Mods::Record.new.from_str(multi_constituent_fixture).related_item
    @citation = Stanford::Mods::Record.new.from_str(citation_fixture).related_item
  end

  it 'excludes related items that will be rendered as a nested record' do
    expect(mods_display_item(@constituent_items).fields).to be_empty
  end

  describe 'label' do
    it 'defaults to Related Item' do
      expect(mods_display_item(@item).fields.first.label).to eq('Related item:')
    end

    it 'gets the location label' do
      expect(mods_display_item(@location).fields.first.label).to eq('Location:')
    end

    it 'gets the reference label' do
      expect(mods_display_item(@reference).fields.first.label).to eq('Referenced by:')
    end

    it 'gets the displayLabel if available' do
      expect(mods_display_item(@display_label).fields.first.label).to eq('Special Item:')
    end
  end

  describe 'fields' do
    it 'gets a location if it is available' do
      fields = mods_display_item(@item).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['A Related Item'])
    end

    it 'returns a link if there is a location/url present' do
      fields = mods_display_item(@linked_item).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(["<a href='http://library.stanford.edu/'>A Related Item</a>"])
    end

    it 'does not return any fields if the described related item is a collection' do
      expect(mods_display_item(@collection).fields).to eq([])
    end

    it 'does not return empty links when there is no title or link' do
      expect(mods_display_item(@blank_item).fields).to eq([])
    end

    it 'concats the isReferencedBy related item title with other metadata' do
      fields = mods_display_item(@reference).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['The title DATE 124'])
    end

    it 'returns the preferred citation if there is no title' do
      fields = mods_display_item(@citation).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to include(/^Sarah Beller, 401 Forbidden/)
    end

    it 'collapses labels down into the same record' do
      fields = mods_display_item(@multi_items).fields
      expect(fields.length).to eq(1)
      expect(fields.first.label).to eq('Related item:')
      expect(fields.first.values.length).to eq(2)
      expect(fields.first.values.first).to(match(%r{<a href=.*>Library</a>}))
      expect(fields.first.values.last).to(match(%r{<a href=.*>SDR</a>}))
    end

    context 'when a value renderer is provided' do
      let(:fields) { related_item.fields }
      let(:related_item) do
        described_class.new(
          @item,
          value_renderer: value_renderer
        )
      end

      # rubocop:disable RSpec/VerifiedDoubles
      let(:value_renderer) { double('ValueRenderer', new: value_renderer_instance) }
      let(:value_renderer_instance) { double('ValueRendererInstance', render: 'rendered value') }
      # rubocop:enable RSpec/VerifiedDoubles

      it 'calls the value renderer to get Values values' do
        expect(value_renderer).to receive(:new).once

        expect(fields.first.values).to eq ['rendered value']
      end
    end
  end
end
