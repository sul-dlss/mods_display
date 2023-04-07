# frozen_string_literal: true

module ModsDisplay
  module RecordHelper
    PERMITTED_TAGS = %w[a dl dd dt i b em strong cite br].freeze

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

    def format_mods_html(val, tags: PERMITTED_TAGS, field: nil)
      # http://daringfireball.net/2010/07/improved_regex_for_matching_urls
      url = %r{(?i)\b(?:https?://|www\d{0,3}[.]|[a-z0-9.-]+[.][a-z]{2,4}/)(?:[^\s()<>]+|\([^\s()<>]+|\([^\s()<>]+\)*\))+(?:\([^\s()<>]+|\([^\s()<>]+\)*\)|[^\s`!()\[\]{};:'".,<>?«»“”‘’])}i
      # http://www.regular-expressions.info/email.html
      email = %r{[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|asia|jobs|museum)\b}i
      matches = [val.scan(url), val.scan(email)].flatten.uniq
      unless val =~ /<a/ # we'll assume that linking has alraedy occured and we don't want to double link
        val = +val # make the string mutable.
        matches.each do |match|
          if match =~ email
            val.gsub!(match, "<a href='mailto:#{match}'>#{match}</a>")
          else
            match = match.delete_suffix('&gt')

            val.gsub!(match, "<a href='#{match}'>#{match}</a>")
          end
        end
      end

      formatted_val = sanitize val, tags: tags, attributes: %w[href]

      # Martin Wong data has significant linebreaks in abstracts and notes that we want
      # to preserve and display in HTML.
      #
      # See https://github.com/sul-dlss/mods_display/issues/78
      simple_formatted_fields = [ModsDisplay::Abstract, ModsDisplay::Contents, ModsDisplay::Note]
      if simple_formatted_fields.any? { |klass| field&.field.is_a? klass } && formatted_val.include?("\n")
        simple_format(formatted_val, {}, sanitize: false)
      else
        formatted_val
      end
    end

    # @private, but used in PURL currently
    def link_urls_and_email(val, tags: %w[a dl dd dt i b em strong cite br])
      format_mods_html(val, tags: tags)
    end
  end
end
