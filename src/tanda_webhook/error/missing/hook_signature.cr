require "colorize"
require "./base"

module Tanda::Webhook
  module Error
    module Missing
      class HookSignature < Base
        private def key : String
          "hook_signature"
        end
      end
    end
  end
end
