require "colorize"
require "json"
require "kemal"

module Tanda::Webhook
  class Server
    HEADERS_STRING        = "Headers:".colorize.yellow
    BODY_STRING           = "Body:".colorize.yellow
    REQUEST_COUNTS_STRING = "Request counts:".colorize.yellow
    SPLITTER              = ("=" * 100).colorize.magenta

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
      @request_counts = RequestCounts.new
    end

    def run
      Kemal.run do
        before_all do |ctx|
          print_splitter
          track_request(ctx)
        end

        post "/", &->handle_post_index(KemalContext)

        after_all do |_ctx|
          log_counts
          print_splitter
        end
      end
    end

    private def handle_post_index(ctx : KemalContext)
      # no content
      ctx.response.status_code = 204

      pretty_print_obj(HEADERS_STRING, ctx.request.headers)
      pretty_print_obj(BODY_STRING, ctx.params.json)
    end

    private def track_request(ctx : KemalContext)
      url = ctx.request.hostname.to_s

      url_counts = @request_counts[url] ||= URLCounts.new
      topic = ctx.params.json["payload"].as(Hash(String, JSON::Any))["topic"].as_s?

      if topic.nil?
        puts "No topic found in payload".colorize.red
        return
      end

      url_counts[topic] ||= 0
      url_counts[topic] += 1
    end

    private def log_counts
      pretty_print_obj(REQUEST_COUNTS_STRING, @request_counts)
    end

    private def pretty_print_obj(header, obj)
      puts
      puts header
      pp obj
      puts
    end

    private def print_splitter
      puts SPLITTER
    end
  end
end
