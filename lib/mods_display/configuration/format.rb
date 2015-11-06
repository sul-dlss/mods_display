module ModsDisplay
  class Configuration
    class Format < Base
      def delimiter(delimiter = '<br/>')
        @delimiter ||= delimiter
      end
    end
  end
end
