require 'spec_helper'

def mods_display_abstract(mods_record)
  ModsDisplay::Abstract.new(mods_record)
end

describe ModsDisplay::Abstract do
  before(:all) do
    @link = Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3"><abstract>A link to the library (http://library.stanford.edu) should appear here</abstract></mods>'
    ).abstract
    @email = Stanford::Mods::Record.new.from_str(
      '<mods xmlns="http://www.loc.gov/mods/v3"><abstract>A link to an email address jdoe@example.com should appear here</abstract></mods>'
    ).abstract
  end

  describe 'labels' do
    it "should get a default 'Abstract' label" do
      fields = mods_display_abstract(@link).fields
      expect(fields.length).to eq(1)
      expect(fields.first.label).to eq('Abstract:')
    end
  end

  describe 'links' do
    it 'should turn URLs into links' do
      expect(mods_display_abstract(@link).to_html).to match(/A link to the library \(<a href/)
      expect(mods_display_abstract(@link).to_html).to match(
        %r{\(<a href="http://library.stanford.edu">http://library.stanford.edu</a>\)}
      )
      expect(mods_display_abstract(@link).to_html).to match(%r{</a>\) should appear here})
    end
    it 'should turn email addresses into mailto links' do
      expect(mods_display_abstract(@email).to_html).to match(
        %r{A link to an email address <a href="mailto:jdoe@example.com">jdoe@example.com</a> should appear here}
      )
    end
  end
end
