require "./base"

module Tanda::Webhook
  module Error
    class NonJSONPayload < Base
      INVALID_JSON_TEXT = "The payload is not valid JSON".colorize.bold.red

      def initialize(exception)
        super(exception.message)
      end

      def pretty_message : String
        INVALID_JSON_TEXT.to_s
      end
    end
  end
end
