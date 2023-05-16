require "json"
require "./webhook_payload"
require "../../error/*"

module Tanda::Webhook
  module Types
    class Webhook
      include JSON::Serializable

      def self.from(request : HTTP::Request) : self | Error::Base
        body = request.body
        puts body
        return Error::MissingPayload.new if body.nil?

        begin
          from_json(body)
        rescue error : JSON::SerializableError
          Error::MalformedPayload.new(body, error)
        end
      end

      getter hook_key : String
      getter hook_time : UInt32
      getter hook_signature : String
      getter payload : WebhookPayload
    end
  end
end
