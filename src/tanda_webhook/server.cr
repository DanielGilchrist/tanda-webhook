require "colorize"
require "json"
require "kemal"

module Tanda::Webhook
  class Server
    HEADERS_STRING        = "Headers:".colorize.yellow
    BODY_STRING           = "Body:".colorize.yellow
    REQUEST_COUNTS_STRING = "Request counts:".colorize.yellow
    SPLITTER              = ("=" * 100).colorize.magenta

    alias KEnv = HTTP::Server::Context

    def self.run
      new.run
    end

    def initialize
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
      @request_counts = Hash(String, Hash(String, Int32)).new
    end

    def run
      Kemal.run do
        before_all &->track_request(KEnv)

        post "/", &->post_index(KEnv)

        after_all &->log_counts(KEnv)
      end
    end

    private def post_index(env : KEnv)
      # no content
      env.response.status_code = 204

      pretty_print_obj(HEADERS_STRING, env.request.headers)
      pretty_print_obj(BODY_STRING, env.params.json)
    end

    private def track_request(env : KEnv)
      url = env.request.hostname.to_s

      url_counts = @request_counts[url] ||= Hash(String, Int32).new
      topic = env.params.json["payload"].as(Hash(String, JSON::Any))["topic"].as_s?

      if topic.nil?
        puts "No topic found in payload".colorize.red
        return
      end

      url_counts[topic] ||= 0
      url_counts[topic] += 1
    end

    private def log_counts(_env : KEnv)
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
