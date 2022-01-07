require 'spec_helper'
require 'fixtures/title_fixtures'

RSpec.describe ModsDisplay::Record do
  include TitleFixtures

  subject(:record) { described_class.new(xml) }
  let(:xml) { simple_title_fixture }

  describe '#mods_record' do
    it 'returns the stanford mods record' do
      expect(record.mods_record).to be_a_kind_of(Stanford::Mods::Record)
    end
  end

  describe '#mods_display_html' do
    it 'returns the ModsDisplay::HTML representation' do
      expect(record.mods_display_html).to be_a_kind_of(ModsDisplay::HTML)
    end
  end
end
