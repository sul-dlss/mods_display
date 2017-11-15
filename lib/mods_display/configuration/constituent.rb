module ModsDisplay
  class Configuration
    class Constituent < Base
      def delimiter(delimiter = ', ')
        @delimiter ||= delimiter
      end
    end
  end
end
