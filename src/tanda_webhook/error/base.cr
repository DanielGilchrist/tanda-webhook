module Tanda::Webhook
  module Error
    abstract class Base < Exception
      def initialize(message)
        super(message)
      end

      abstract def pretty_message

      def handle!
        {% if flag?(:debug) %}
          raise self
        {% else %}
          puts pretty_message
        {% end %}
      end
    end
  end
end
