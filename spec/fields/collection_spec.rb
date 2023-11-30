# frozen_string_literal: true

def mods_display_collection(mods_record)
  ModsDisplay::Collection.new(
    mods_record
  )
end

describe ModsDisplay::Collection do
  let(:collection) do
    Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem>
          <titleInfo><title>The Collection</title></titleInfo><typeOfResource collection="yes" />
        </relatedItem>
      </mods>'
    ).related_item
  end
  let(:non_collection) do
    Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3"><relatedItem><titleInfo><title>Not a Collection</title></titleInfo></relatedItem></mods>'
    ).related_item
  end
  let(:display_label) do
    Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3">
         <relatedItem displayLabel="Special Collection">
           <titleInfo><title>Not a Collection</title></titleInfo>
         </relatedItem>
       </mods>'
    ).related_item
  end
  let(:multiple_related_items) do
    Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3">
        <relatedItem displayLabel="Special Collection">
          <titleInfo><title>Not a Collection</title></titleInfo>
        </relatedItem>
        <relatedItem>
          <titleInfo><title>The Collection</title></titleInfo><typeOfResource collection="yes" />
        </relatedItem>
      </mods>'
    ).related_item
  end

  describe 'label' do
    it 'defaults to Collection' do
      expect(mods_display_collection(collection).fields.first.label).to eq('Collection:')
    end

    it 'gets the displayLabel if available' do
      expect(mods_display_collection(display_label).label).to eq('Special Collection:')
    end

    it 'gets the proper titles of all items when there is a displayLabel present' do
      expect(mods_display_collection(multiple_related_items).fields.first.label).to eq 'Collection:'
    end
  end

  describe 'fields' do
    it 'gets a collection title if there is an appropriate typeOfResource field with the collection attribute' do
      fields = mods_display_collection(collection).fields
      expect(fields.length).to eq(1)
      expect(fields.first.values).to eq(['The Collection'])
    end

    it 'is blank if the there is not an appropriate typeOfResource field with the collection attribute' do
      expect(mods_display_collection(non_collection).fields).to eq([])
    end
  end
end
