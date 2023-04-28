require "colorize"
require "file_utils"
require "json"
require "kemal"

require "./types/webhook"

module Tanda::Webhook
  class Server
    HEADERS_STRING        = "Headers:".colorize.yellow
    BODY_STRING           = "Body:".colorize.yellow
    REQUEST_COUNTS_STRING = "Request counts:".colorize.yellow
    SPLITTER              = ("=" * 100).colorize.magenta
    FILE_TIME_FORMAT      = "%Y-%m-%d-%H-%M-%S"
    OUTPUT_DIR            = "output"
    TOTAL                 = "total"

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
    alias RequestCounts = Hash(String, URLCounts)
    alias URLCounts = Hash(String, UInt32)

    alias KemalContext = HTTP::Server::Context

    def self.run
      new.run
    end

    def initialize
      @requests = {counts: RequestCounts.new, requests: Array({headers: HTTP::Headers, body: Types::Webhook}).new}
    end

    def run
      Kemal.run do
        post "/" do |ctx|
          ctx.response.status_code = 204

          splitters do
            track_and_log_request(ctx)
            log_counts
          end
        end
      end
    ensure
      write_to_json_file
    end

    private def write_to_json_file
      return if request_counts.empty?

      time = Time.local
      formatted_time = Time::Format.new(FILE_TIME_FORMAT).format(time)
      filename = "#{OUTPUT_DIR}/requests-#{formatted_time}.json"

      create_output_dir_if_not_exists

      puts "Writing output to #{filename}...".colorize.green
      File.write(filename, content: @requests.to_json)
      puts "Done!".colorize.green
    end

    def create_output_dir_if_not_exists
      FileUtils.mkdir_p(OUTPUT_DIR) unless File.directory?(OUTPUT_DIR)
    end

    private def track_and_log_request(ctx : KemalContext)
      webhook = Types::Webhook.from(ctx.request)
      return puts "Webhook payload is empty!".colorize.red if webhook.nil?

      @requests[:requests] << {headers: ctx.request.headers, body: webhook}

      url = ctx.request.hostname.to_s
      url_counts = request_counts[url] ||= URLCounts.new
      topic = webhook.payload.topic

      url_counts[TOTAL] ||= 0
      url_counts[TOTAL] += 1
      url_counts[topic] ||= 0
      url_counts[topic] += 1

      pretty_print_obj(HEADERS_STRING, ctx.request.headers.to_h)
      pretty_print_obj(BODY_STRING, JSON.parse(webhook.to_json))
    end

    private def request_counts
      @requests[:counts]
    end

    private def log_counts
      pretty_print_obj(REQUEST_COUNTS_STRING, request_counts)
    end

    private def pretty_print_obj(header, obj)
      puts
      puts header
      pp obj
      puts
    end

    private def splitters(&)
      print_splitter
      yield
      print_splitter
    end

    private def print_splitter
      puts SPLITTER
    end
  end
end
