# frozen_string_literal: true

require 'stanford-mods'

##
# A convenience object for parsing and rendering MODS
module ModsDisplay
  class Record
    attr_reader :xml

    def initialize(xml)
      @xml = xml
    end

    def mods_record
      return if xml.nil?
      @mods_record ||= Stanford::Mods::Record.new.tap { |mods| mods.from_str(xml, false) }
    end

    def mods_display_html
      return unless mods_record

      ModsDisplay::HTML.new(mods_record)
    end
  end
end
