require "colorize"
require "./base"

module Tanda::Webhook
  module Error
    class MissingSignature < Base
      ERROR_MESSAGE = "Request signature is missing!"

      def initialize
        super(ERROR_MESSAGE)
      end

      def pretty_message
        message.colorize.red
      end
    end
  end
end
