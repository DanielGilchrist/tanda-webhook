require "json"
require "./webhook_payload"
require "../error/*"

module Tanda::Webhook
  module Types
    class UnverifiedWebhook
      include JSON::Serializable

      def self.from(body_string : String) : self | Error::Base
        from_json(body_string)
      rescue ex : JSON::SerializableError | JSON::ParseException
        Error::MalformedPayload.new(body_string, ex)
      end

      getter hook_key : String?
      getter hook_time : UInt32?
      getter hook_signature : String?
      getter payload : WebhookPayload?

      def to_webhook : Webhook | Error::Base
        hook_key = self.hook_key
        return Error::Missing::HookKey.new if hook_key.nil?

        hook_time = self.hook_time
        return Error::Missing::HookTime.new if hook_time.nil?

        hook_signature = self.hook_signature
        return Error::Missing::HookSignature.new if hook_signature.nil?

        payload = self.payload
        return Error::Missing::WebhookPayload.new if payload.nil?

        Webhook.new(hook_key, hook_time, hook_signature, payload)
      end
    end
  end
end
