module ModsDisplay
  class Configuration
    class Base
      def initialize(&config)
        instance_eval(&config) if block_given?
      end

      def label_class(label_class = '')
        @label_class ||= label_class
      end

      def value_class(value_class = '')
        @value_class ||= value_class
      end

      def delimiter(delimiter = ', ')
        @delimiter ||= delimiter
      end

      def link(method_name = '', args = {})
        return @link if method_name == ''
        @link ||= [method_name, args]
      end

      def ignore!
        @ignore = true
      end

      def ignore?
        @ignore || false
      end
    end
  end
end
