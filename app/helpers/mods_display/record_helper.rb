# frozen_string_literal: true

require 'rails_autolink/helpers'

module ModsDisplay
  module RecordHelper
    def mods_display_label(label)
      content_tag(:dt, label.delete(':')) + "\n".html_safe
    end

    # @private
    def mods_display_content(values, delimiter = nil)
      mods_record_field ModsDisplay::Values.new(values: Array(values)), delimiter
    end

    def mods_record_field(field, delimiter = nil, component: ModsDisplay::FieldComponent, &block)
      render component.new(field: field, delimiter: delimiter, value_transformer: block)
    end

    # this returns a role's label and the display names for ModsDisplay:Name:Person
    def mods_name_field(field)
      mods_record_field(field) do |name|
        block_given? ? capture { yield(name.name) } : name.name
      end
    end

    def mods_display_name(values, &block)
      mods_name_field(ModsDisplay::Values.new(values: Array(values)), &block)
    end

    # We need this to remove the ending ":" from the role labels only in data from
    # mods_display
    # @private (but currently used in searchworks)
    def sanitize_mods_name_label(label)
      label.sub(/:$/, '')
    end

    def mods_subject_field(field, &block)
      mods_record_field(field) do |subject_line|
        safe_join(link_mods_subjects(subject_line, &block), ' > ')
      end
    end

    def mods_genre_field(field, &block)
      mods_record_field(field) do |genre_line|
        link_to_mods_subject(genre_line, &block)
      end
    end

    # @private
    def link_mods_genres(genre, &block)
      link_buffer = []
      link_to_mods_subject(genre, link_buffer, &block)
    end

    # @private
    def link_mods_subjects(subjects, &block)
      link_buffer = []
      linked_subjects = []
      subjects.each do |subject|
        linked_subjects << link_to_mods_subject(subject, link_buffer, &block) if subject.present?
      end
      linked_subjects
    end

    # @private
    def link_to_mods_subject(subject, buffer = [])
      subject_text = subject.respond_to?(:name) ? subject.name : subject
      link = block_given? ? capture { yield(subject_text, buffer) } : subject_text
      buffer << subject_text.strip
      link << " (#{subject.roles.join(', ')})" if subject.respond_to?(:roles) && subject.roles.present?
      link
    end

    class MetadataScrubber < Rails::Html::PermitScrubber
      # Override the superclass to escape the non-permitted nodes
      def scrub_node(node)
        node.add_next_sibling Nokogiri::XML::Text.new(node.to_s, node.document)
        node.remove
      end
    end

    def format_mods_html(val, tags: %w[a dl dd dt i b em strong cite br], field: nil)
      scrubber = MetadataScrubber.new
      scrubber.tags = tags

      formatted_val = Loofah.fragment(val).scrub!(scrubber).to_s

      formatted_val = auto_link(formatted_val) unless formatted_val =~ /<a/ # we'll assume that linking has alraedy occured and we don't want to double link

      # Martin Wong data has significant linebreaks in abstracts and notes that we want
      # to preserve and display in HTML.
      #
      # Some user-deposited items have complex use and reproduction statements that also
      # need linebreaks preserved.
      #
      # See https://github.com/sul-dlss/mods_display/issues/78
      # and https://github.com/sul-dlss/mods_display/issues/145
      simple_formatted_fields = [ModsDisplay::Abstract, ModsDisplay::Contents, ModsDisplay::Note, ModsDisplay::AccessCondition]
      if simple_formatted_fields.any? { |klass| field&.field.is_a? klass } && formatted_val.include?("\n")
        simple_format(formatted_val, {}, sanitize: false)
      else
        formatted_val.html_safe
      end
    end

    # @private, but used in PURL currently
    def link_urls_and_email(val, tags: %w[a dl dd dt i b em strong cite br])
      format_mods_html(val, tags: tags)
    end
  end
end
