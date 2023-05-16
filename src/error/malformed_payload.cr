require "./base"

module Tanda::Webhook
  module Error
    class MalformedPayload < Base
      def initialize(@body : IO, exception : JSON::SerializableError)
        super(exception.message)
      end

      def pretty_message
        pretty_json = try_pretty_parse_body
        "Malformed payload:\n#{pretty_json}".colorize.red
      end

      def try_pretty_parse_body
        begin
          JSON.parse(@body).to_pretty_json
        rescue JSON::ParseException
          @body.to_s
        end
      end
    end
  end
end
