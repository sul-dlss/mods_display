module ModsDisplay
  class Configuration
    class Subject < Base
      def hierarchical_link(hierarchical_link = false)
        @hierarchical_link ||= hierarchical_link
      end

      def delimiter(delimiter = ' &gt; ')
        @delimiter ||= delimiter
      end
    end
  end
end
