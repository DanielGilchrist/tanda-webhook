require "json"
require "./webhook_payload"
require "../error/*"

module Tanda::Webhook
  module Types
    class Webhook
      include JSON::Serializable

      def self.from(request : HTTP::Request) : self | Error::Base
        request_body = request.body
        return Error::MissingPayload.new if request_body.nil?

        # TODO: Avoid building a String if possible
        # This is a hack to get around needing to potentially consume the request body IO twice
        # It'd be nice if we could rewind the IO, but I haven't been able to figure out how yet
        body_string = String.build do |io|
          IO.copy(request_body, io)
        end

        begin
          from_json(body_string)
        rescue ex : JSON::SerializableError | JSON::ParseException
          Error::MalformedPayload.new(body_string, ex)
        end
      end

      getter hook_key : String
      getter hook_time : UInt32
      getter hook_signature : String
      getter payload : WebhookPayload
    end
  end
end
