# frozen_string_literal: true

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

    it 'returns a single <dl>' do
      expect(record.mods_display_html.to_html.scan(/<dl>/).length).to eq(1)
      expect(record.mods_display_html.to_html.scan(%r{</dl>}).length).to eq(1)
    end

    it 'returns a dt/dd pair for each piece of metadata in the mods' do
      expect(record.mods_display_html.to_html.scan(/<dt/).length).to eq(1)
      expect(record.mods_display_html.to_html.scan(/<dd>/).length).to eq(1)
    end

    it 'returns a proper label' do
      expect(record.mods_display_html.to_html.scan(%r{<dt>Title</dt>}).length).to eq(1)
    end

    it 'returns a proper value' do
      expect(record.mods_display_html.to_html.scan(%r{<dd>\s*Title\s*</dd>}).length).to eq(1)
    end
  end
end
