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
    alias RequestCounts = Hash(String, Hash(String, Int32))
    alias KemalContext = HTTP::Server::Context

    def self.run
      new.run
    end

    def initialize
      @request_counts = RequestCounts.new
    end

    def run
      Kemal.run do
        before_all &->track_request(KemalContext)

        post "/", &->handle_post_index(KemalContext)

        after_all &->log_counts(KemalContext)
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

      url_counts = @request_counts[url] ||= Hash(String, Int32).new
      topic = ctx.params.json["payload"].as(Hash(String, JSON::Any))["topic"].as_s?

      if topic.nil?
        puts "No topic found in payload".colorize.red
        return
      end

      url_counts[topic] ||= 0
      url_counts[topic] += 1
    end

    private def log_counts(_ctx : KemalContext)
      pretty_print_obj(REQUEST_COUNTS_STRING, @request_counts)
      puts SPLITTER
    end

    private def pretty_print_obj(header, obj)
      puts
      puts header
      pp obj
      puts
    end
  end
end
