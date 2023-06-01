require "json"
require "./webhook_payload"
require "../../error/*"

module Tanda::Webhook
  module Types
    class Webhook
      include JSON::Serializable

      def self.from(request : HTTP::Request) : self | Error::Base
        request_body = request.body
        return Error::MissingPayload.new if request_body.nil?

        # We need to copy the IO to an IO::Memory because if the JSON can't be parsed initially
        # the IO would be consumed and needs to be rewinded so we can try again
        body = IO::Memory.new
        IO.copy(request_body, body)

        begin
          from_json(body)
        rescue error : JSON::SerializableError | JSON::ParseException
          begin
            body.rewind
            json = body.gets_to_end
            Error::MalformedPayload.new(json, error)
          rescue error : JSON::ParseException
            Error::NonJSONPayload.new(error)
          end
        end
      end

      getter hook_key : String
      getter hook_time : UInt32
      getter hook_signature : String
      getter payload : WebhookPayload
    end
  end
end
