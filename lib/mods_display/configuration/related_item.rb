module ModsDisplay
  class Configuration
    class RelatedItem < Base
      def delimiter(delimiter = '<br/>')
        @delimiter ||= delimiter
      end
    end
  end
end
