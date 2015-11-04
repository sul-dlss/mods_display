module ModsDisplay
  class Configuration
    class Title < Base
      def delimiter(delimiter = '<br/>')
        @delimiter ||= delimiter
      end
    end
  end
end
