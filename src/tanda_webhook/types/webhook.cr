require "json"
require "./webhook_payload"
require "../error/*"

module Tanda::Webhook
  module Types
    class Webhook
      include JSON::Serializable

      def initialize(@hook_key : String, @hook_time : UInt32, @hook_signature : String, @payload : WebhookPayload); end

      getter hook_key : String
      getter hook_time : UInt32
      getter hook_signature : String
      getter payload : WebhookPayload
    end
  end
end
