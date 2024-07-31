require "colorize"
require "./base"

module Tanda::Webhook
  module Error
    module Missing
      class HookKey < Base
        private def key : String
          "hook_key"
        end
      end
    end
  end
end
