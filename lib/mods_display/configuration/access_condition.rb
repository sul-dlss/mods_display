module ModsDisplay
  class Configuration
    class AccessCondition < Base
      def delimiter(delimiter = '<br/>')
        @delimiter ||= delimiter
      end

      def ignore?
        @ignore.nil? ? true : @ignore
      end

      def display!
        @ignore = false
      end

      def cc_license_version(cc_license_version = '3.0')
        @cc_license_version ||= cc_license_version
      end
    end
  end
end
