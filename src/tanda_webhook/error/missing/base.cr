require "colorize"
require "../base"

module Tanda::Webhook
  module Error
    module Missing
      abstract class Base < Error::Base
        def initialize
          super("Webhook is missing '#{key}'")
        end

        def pretty_message
          message.colorize.red
        end

        private abstract def key : String
      end
    end
  end
end
