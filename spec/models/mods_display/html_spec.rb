# frozen_string_literal: true

RSpec.describe ModsDisplay::HTML do
  let(:instance) { described_class.new(stanford_mods) }
  let(:stanford_mods) { Stanford::Mods::Record.new.tap { |record| record.from_str(mods) } }

  describe '#title' do
    subject { instance.title }

    context 'with a primary title that is not in the first position' do
      let(:mods) do
        <<~MODS
          <?xml version="1.0" encoding="UTF-8"?>
          <mods xmlns="http://www.loc.gov/mods/v3" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="3.3" xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-3.xsd">
            <titleInfo type="alternative" altRepGroup="1">
              <title>[Pukhan p'osŭt'ŏ k'ŏlleksyŏn]</title>
            </titleInfo>
            <titleInfo type="alternative" altRepGroup="1">
              <title>[북한 포스터 컬렉션]</title>
            </titleInfo>
            <titleInfo usage="primary">
              <nonSort>[ </nonSort>
              <title>North Korean poster collection]</title>
            </titleInfo>
          </mods>
        MODS
      end

      it { is_expected.to eq ['[ North Korean poster collection]'] }
    end
  end
end
