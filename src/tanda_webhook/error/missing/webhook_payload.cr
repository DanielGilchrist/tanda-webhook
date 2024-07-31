require "colorize"
require "./base"

module Tanda::Webhook
  module Error
    module Missing
      class WebhookPayload < Base
        private def key : String
          "payload"
        end
      end
    end
  end
end
