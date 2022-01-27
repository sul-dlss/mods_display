# frozen_string_literal: true

require 'spec_helper'
require 'byebug'

describe ModsDisplay::RecordHelper, type: :helper do
  let(:empty_field) { OpenStruct.new(label: 'test', values: ['']) }

  describe 'mods_display_label' do
    it 'returns correct label' do
      expect(helper.mods_display_label('test:')).not_to have_content ':'
      expect(helper.mods_display_label('test:')).to have_css('dt', text: 'test')
    end
  end

  describe 'mods_display_content' do
    it 'returns correct content' do
      expect(helper.mods_display_content('hello, there')).to have_css('dd', text: 'hello, there')
    end

    it 'returns multiple dd elements when a multi-element array is passed' do
      expect(helper.mods_display_content(%w[hello there])).to have_css('dd', count: 2)
    end

    it 'handles nil values correctly' do
      expect(helper.mods_display_content(['something', nil])).to have_css('dd', count: 1)
    end
  end

  describe 'mods_record_field' do
    let(:mods_field) { OpenStruct.new(label: 'test', values: ['hello, there']) }
    let(:url_field) { OpenStruct.new(label: 'test', values: ['https://library.stanford.edu']) }
    let(:multi_values) { double(label: 'test', values: %w[123 321]) }

    it 'returns correct content' do
      expect(helper.mods_record_field(mods_field)).to have_css('dt', text: 'test')
      expect(helper.mods_record_field(mods_field)).to have_css('dd', text: 'hello, there')
    end

    it 'links fields with URLs' do
      expect(helper.mods_record_field(url_field)).to have_css("a[href='https://library.stanford.edu']", text: 'https://library.stanford.edu')
    end

    it 'does not print empty labels' do
      expect(helper.mods_record_field(empty_field)).not_to be_present
    end

    it 'joins values with a <dd> by default' do
      expect(helper.mods_record_field(multi_values)).to have_css('dd', count: 2)
    end

    it 'joins values with a supplied delimiter' do
      expect(helper.mods_record_field(multi_values, 'DELIM')).to have_css('dd', count: 1)
      expect(helper.mods_record_field(multi_values, 'DELIM')).to have_css('dd', text: '123DELIM321')
    end
  end

  describe 'names' do
    let(:name_field) do
      OpenStruct.new(
        label: 'Contributor',
        values: [
          OpenStruct.new(name: 'Winefrey, Oprah', roles: %w[Host Producer]),
          OpenStruct.new(name: 'Kittenz, Emergency')
        ]
      )
    end

    describe '#mods_name_field' do
      it 'joins the label and values' do
        name = mods_name_field(name_field) do |name|
          link_to(name, searches_path(q: "\"#{name}\"", search_field: 'search_author'))
        end
        expect(name).to match(%r{<dt>Contributor</dt>})
        expect(name).to match(%r{<dd><a href.*</dd>})
      end

      it 'does not print empty labels' do
        expect(mods_name_field(empty_field)).not_to be_present
      end
    end

    describe '#mods_display_name' do
      let(:name) do
        mods_display_name(name_field.values) do |name|
          link_to(name, searches_path(q: "\"#{name}\"", search_field: 'search_author'))
        end
      end

      it 'links to the name' do
        expect(name).to match(%r{<a href=.*%22Winefrey%2C\+Oprah%22.*>Winefrey, Oprah</a>})
        expect(name).to match(%r{<a href=.*%22Kittenz%2C\+Emergency%22.*>Kittenz, Emergency</a>})
      end

      it 'links to an author search' do
        expect(name).to match(/<a href.*search_field=search_author.*>/)
      end
    end

    describe '#sanitize_mods_name_label' do
      it 'removes a ":" at the end of label if present' do
        expect(sanitize_mods_name_label('Test String:')).to eq 'Test String'
        expect(sanitize_mods_name_label('Test String')).to eq 'Test String'
      end
    end
  end

  describe 'subjects' do
    let(:subjects) do
      [OpenStruct.new(label: 'Subjects', values: [%w[Subject1a Subject1b], %w[Subject2a Subject2b Subject2c]])]
    end
    let(:name_subjects) do
      [OpenStruct.new(label: 'Subjects', values: [OpenStruct.new(name: 'Person Name', roles: %w[Role1 Role2])])]
    end
    let(:genres) { [OpenStruct.new(label: 'Genres', values: %w[Genre1 Genre2 Genre3])] }

    describe '#mods_subject_field' do
      let(:subject) do
        mods_subject_field(subjects.first) do |subject_text|
          link_to(
            subject_text,
            searches_path(
              q: "\"#{[[], subject_text.strip].flatten.join(' ')}\"",
              search_field: 'subject_terms'
            )
          )
        end
      end

      it 'joins the subject fields in a dd' do
        expect(subject).to match(%r{<dd><a href=*.*">Subject1a*.*Subject1b</a></dd>\s*<dd><a})
      end

      it "joins the individual subjects with a '>'" do
        expect(subject).to match(%r{Subject2b</a> &gt; <a href})
      end

      it 'does not print empty labels' do
        expect(mods_subject_field(empty_field)).not_to be_present
      end
    end

    describe '#mods_genre_field' do
      it 'joins the genre fields with a dd' do
        expect(mods_genre_field(genres.first) do |text|
          link_to(text, searches_path(q: text))
        end).to match(%r{<dd><a href=*.*>Genre1*.*</a></dd>\s*<dd><a*.*Genre2</a></dd>})
      end

      it 'does not print empty labels' do
        expect(mods_genre_field(empty_field)).not_to be_present
      end
    end

    describe '#link_mods_subjects' do
      let(:linked_subjects) do
        link_mods_subjects(subjects.first.values.last) do |subject_text, buffer|
          link_to(
            subject_text,
            searches_path(
              q: "\"#{[buffer, subject_text.strip].flatten.join(' ')}\"",
              search_field: 'subject_terms'
            )
          )
        end
      end

      it 'returns all subjects' do
        expect(linked_subjects.length).to eq 3
      end

      it 'links to the subject hierarchically' do
        expect(linked_subjects[0]).to match(%r{^<a href=.*q=%22Subject2a%22.*>Subject2a</a>$})
        expect(linked_subjects[1]).to match(%r{^<a href=.*q=%22Subject2a\+Subject2b%22.*>Subject2b</a>$})
        expect(linked_subjects[2]).to match(%r{^<a href=.*q=%22Subject2a\+Subject2b\+Subject2c%22.*>Subject2c</a>$})
      end

      it 'links to subject terms search field' do
        linked_subjects.each do |subject|
          expect(subject).to match(/search_field=subject_terms/)
        end
      end
    end

    describe '#link_mods_genres' do
      let(:linked_genres) do
        link_mods_genres(genres.first.values.last) do |text|
          link_to(
            text,
            searches_path(
              q: "\"#{[[], text.strip].flatten.join(' ')}\"",
              search_field: 'subject_terms'
            )
          )
        end
      end

      it 'returns correct link' do
        expect(linked_genres).to match(%r{<a href=*.*Genre3*.*</a>})
      end

      it 'links to subject terms search field' do
        expect(linked_genres).to match(/search_field=subject_terms/)
      end
    end

    describe '#link_to_mods_subject' do
      it 'handles subjects that behave like names' do
        name_subject = link_to_mods_subject(name_subjects.first.values.first, []) do |subject_text|
          link_to(
            subject_text,
            searches_path(
              q: "\"#{[[], subject_text.strip].flatten.join(' ')}\"",
              search_field: 'subject_terms'
            )
          )
        end
        expect(name_subject).to match(%r{<a href=.*%22Person\+Name%22.*>Person Name</a> \(Role1, Role2\)})
      end
    end
  end

  describe '#link_urls_and_email' do
    let(:url) { 'This is a field that contains an https://library.stanford.edu URL' }
    let(:email) { 'This is a field that contains an email@email.com address' }

    it 'links URLs' do
      expect(link_urls_and_email(url)).to eq 'This is a field that contains an <a href="https://library.stanford.edu">https://library.stanford.edu</a> URL'
    end

    it 'links email addresses' do
      expect(link_urls_and_email(email)).to eq 'This is a field that contains an <a href="mailto:email@email.com">email@email.com</a> address'
    end
  end
end
