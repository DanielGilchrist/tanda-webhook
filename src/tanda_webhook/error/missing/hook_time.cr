require "colorize"
require "./base"

module Tanda::Webhook
  module Error
    module Missing
      class HookTime < Base
        private def key : String
          "hook_time"
        end
      end
    end
  end
end
