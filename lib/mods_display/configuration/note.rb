module ModsDisplay
  class Configuration
    class Note < Base
      def delimiter(delimiter = '<br/>')
        @delimiter ||= delimiter
      end
    end
  end
end
