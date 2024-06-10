require "colorize"
require "./base"

module Tanda::Webhook
  module Error
    class SignatureMismatch < Base
      ERROR_MESSAGE = "Signatures do not match!".colorize.red.bold
      EXPECTED      = "Expected:".colorize.red.bold
      ACTUAL        = "Actual:".colorize.red.bold

      def initialize(expected : String, actual : String)
        super("#{ERROR_MESSAGE}\n#{EXPECTED} #{expected}\n#{ACTUAL} #{actual}")
      end

      def pretty_message
        message
      end
    end
  end
end
