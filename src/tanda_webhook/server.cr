require "colorize"
require "file_utils"
require "json"
require "kemal"
require "openssl/hmac"

require "./error/**"
require "./request_log"
require "./terminal"
require "./types/unverified_webhook"
require "./types/webhook"

module Tanda::Webhook
  class Server
    HEADERS_STRING   = "Headers:".colorize.yellow
    BODY_STRING      = "Body:".colorize.yellow
    FILE_TIME_FORMAT = "%Y-%m-%d-%H-%M-%S"
    OUTPUT_DIR       = "output"
    DEFAULT_COLUMNS  = 100

    alias KemalContext = HTTP::Server::Context

    @splitter : Colorize::Object(String)? = nil

    def self.run
      new.run
    end

    def initialize
      @secret = ENV["TANDA_WEBHOOK_SECRET_KEY"]?
      @request_log = RequestLog.new
    end

    def run
      output_secret_key_header

      Kemal.run do
        post "/" do |ctx|
          ctx.response.status_code = 204

          splitters do
            track_and_log_request(ctx)
            @request_log.log_counts
          end
        end
      end
    ensure
      write_to_json_file
    end

    private def write_to_json_file
      return if @request_log.empty?

      time = Time.local
      formatted_time = Time::Format.new(FILE_TIME_FORMAT).format(time)
      filename = "#{OUTPUT_DIR}/requests-#{formatted_time}.json"

      create_output_dir_if_not_exists

      puts "Writing output to #{filename}...".colorize.green
      File.write(filename, content: @request_log.to_json)
      puts "Done!".colorize.green
    end

    private def create_output_dir_if_not_exists
      FileUtils.mkdir_p(OUTPUT_DIR) unless File.directory?(OUTPUT_DIR)
    end

    private def track_and_log_request(ctx : KemalContext)
      request = ctx.request
      webhook = parse_and_verify_webhook(request)
      return webhook.handle! if webhook.is_a?(Error::Base)

      @request_log.record_webhook!(request, webhook)

      puts "Valid webhook received!".colorize.green if @secret
      puts "#{"Secret".colorize.yellow}: #{@secret}" if @secret
      Helpers.pretty_print_obj(HEADERS_STRING, request.headers.to_h)
      Helpers.pretty_print_obj(BODY_STRING, JSON.parse(webhook.to_json))
    end

    private def parse_and_verify_webhook(request : HTTP::Request) : Types::Webhook | Error::Base
      request_body = request.body
      return Error::MissingPayload.new if request_body.nil?

      body_string = request_body.gets_to_end

      if secret = @secret
        expected_signature = request.headers["X-Webhook-Signature"]?
        return Error::MissingSignature.new if expected_signature.nil? || expected_signature.blank?

        actual_signature = OpenSSL::HMAC.hexdigest(:sha1, secret, body_string)
        return Error::SignatureMismatch.new(expected_signature, actual_signature) if expected_signature != actual_signature
      end

      unverified_webhook = Types::UnverifiedWebhook.from(body_string)
      return unverified_webhook if unverified_webhook.is_a?(Error::Base)

      unverified_webhook.to_webhook
    end

    private def splitters(&)
      print_splitter
      yield
      print_splitter
    end

    private def print_splitter
      puts splitter
    end

    private def splitter : Colorize::Object(String)
      @splitter ||= begin
        terminal = Terminal.new
        window = terminal.window
        columns = window.columns || DEFAULT_COLUMNS

        ("=" * columns).colorize.magenta
      end
    end

    private def output_secret_key_header
      if @secret
        puts "Using \"#{@secret}\" for webhook verification checks".colorize.white.bold
      else
        puts "No secret key provided - skipping webhook verification checks".colorize.white.bold
        puts "To verify webhooks set the TANDA_WEBHOOK_SECRET_KEY environment variable"
      end
      puts
    end
  end
end
