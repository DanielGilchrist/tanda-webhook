require "colorize"
require "./base"

module Tanda::Webhook
  module Error
    class MissingPayload < Base
      ERROR_MESSAGE = "Webhook payload is empty!"

      def initialize
        super(ERROR_MESSAGE)
      end

      def pretty_message
        message.colorize.red
      end
    end
  end
end
