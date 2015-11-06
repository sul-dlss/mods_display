module ModsDisplay
  class Configuration
    class Genre < Base
      def delimiter(delimiter = '<br/>')
        @delimiter ||= delimiter
      end
    end
  end
end
