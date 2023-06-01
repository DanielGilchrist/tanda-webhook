require "./base"

module Tanda::Webhook
  module Error
    class MalformedPayload < Base
      MALFORMED_PAYLOAD_TEXT = "Malformed payload:".colorize.bold.red

      def initialize(@body : String, exception)
        super(exception.message)
      end

      def pretty_message : String
        pretty_json = try_pretty_parse_body.colorize.light_red
        "#{MALFORMED_PAYLOAD_TEXT}\n#{pretty_json}"
      end

      def try_pretty_parse_body
        JSON.parse(@body).to_pretty_json
      rescue JSON::ParseException
        @body
      end
    end
  end
end
