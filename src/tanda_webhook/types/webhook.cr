require "json"

require "./webhook_payload"

module Tanda::Webhook
  module Types
    class Webhook
      include JSON::Serializable

      def self.from(request : HTTP::Request) : self?
        body = request.body
        return if body.nil?

        from_json(body)
      end

      getter hook_key : String
      getter hook_time : UInt32
      getter hook_signature : String
      getter payload : WebhookPayload
    end
  end
end
