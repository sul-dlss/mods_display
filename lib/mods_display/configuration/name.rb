module ModsDisplay
  class Configuration
    class Name < Base
      def delimiter(delimiter = '<br/>')
        @delimiter ||= delimiter
      end
    end
  end
end
