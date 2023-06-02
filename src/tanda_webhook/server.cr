require "colorize"
require "file_utils"
require "json"
require "kemal"

require "./types/webhook"

module Tanda::Webhook
  class Server
    HEADERS_STRING   = "Headers:".colorize.yellow
    BODY_STRING      = "Body:".colorize.yellow
    SPLITTER         = ("=" * 100).colorize.magenta
    FILE_TIME_FORMAT = "%Y-%m-%d-%H-%M-%S"
    OUTPUT_DIR       = "output"

    alias KemalContext = HTTP::Server::Context

    def self.run
      new.run
    end

    def initialize
      @request_log = RequestLog.new
    end

    def run
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

    def create_output_dir_if_not_exists
      FileUtils.mkdir_p(OUTPUT_DIR) unless File.directory?(OUTPUT_DIR)
    end

    private def track_and_log_request(ctx : KemalContext)
      webhook = Types::Webhook.from(ctx.request)
      return webhook.handle! if webhook.is_a?(Error::Base)

      url = ctx.request.hostname.to_s
      topic = webhook.payload.topic

      @request_log.increment_request_counts!(url, topic)
      @request_log.set_request!(headers: ctx.request.headers, body: webhook)

      Helpers.pretty_print_obj(HEADERS_STRING, ctx.request.headers.to_h)
      Helpers.pretty_print_obj(BODY_STRING, JSON.parse(webhook.to_json))
    end

    private def splitters(&)
      print_splitter
      yield
      print_splitter
    end

    private def print_splitter
      puts SPLITTER
    end

    private module Helpers
      extend self

      def pretty_print_obj(header, obj)
        puts
        puts header
        pp obj
        puts
      end
    end

    private class RequestLog
      include JSON::Serializable

      REQUEST_COUNTS_STRING = "Request counts:".colorize.yellow
      TOTAL_COUNT_KEY       = "total"

      alias Requests = Array({headers: HTTP::Headers, body: Types::Webhook})

      # {
      #   "https://some_url.com" => {
      #     "schedule.published" => 1,
      #     "schedule.updated" => 2,
      #   },
      #   "https://some_other_url.com" => {
      #     "shift.updated" => 1,
      #     "schedule.published" => 2,
      #   },
      # }
      alias RequestCounts = Hash(String, TopicCounts)
      alias TopicCounts = Hash(String, UInt32)

      def initialize
        @counts = RequestCounts.new do |request_counts, url_or_total|
          request_counts[url_or_total] = TopicCounts.new do |topic_counts, topic|
            topic_counts[topic] = 0
          end
        end
        @requests = Requests.new
      end

      def set_request!(headers : HTTP::Headers, body : Types::Webhook)
        @requests << {headers: headers, body: body}
      end

      def increment_request_counts!(url : String, topic : String)
        @counts[TOTAL_COUNT_KEY][topic] += 1
        @counts[url][topic] += 1
      end

      def log_counts
        Helpers.pretty_print_obj(REQUEST_COUNTS_STRING, @counts)
      end

      def empty? : Bool
        @counts.empty?
      end

      private getter counts : RequestCounts
      private getter requests : Array({headers: HTTP::Headers, body: Types::Webhook})
    end
  end
end
