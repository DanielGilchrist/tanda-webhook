require "json"
require "./webhook_payload"
require "../error/*"

module Tanda::Webhook
  module Types
    class Webhook
      include JSON::Serializable

      def self.from(body_string : String) : self | Error::Base
        from_json(body_string)
      rescue ex : JSON::SerializableError | JSON::ParseException
        Error::MalformedPayload.new(body_string, ex)
      end

      getter hook_key : String
      getter hook_time : UInt32
      getter hook_signature : String
      getter payload : WebhookPayload
    end
  end
end
