require "colorize"
require "json"
require "kemal"

module Tanda::Webhook
  class Server
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

      puts "\nHeaders: #{env.request.headers}\n"
      puts "\nBody: #{env.params.json}\n"
    end

    private def track_request(env : KEnv)
      url = env.request.hostname.to_s

      url_counts = @request_counts[url] ||= Hash(String, Int32).new
      topic = env.params.json["payload"].as(Hash(String, JSON::Any))["topic"].as_s?
      return unless topic

      url_counts[topic] ||= 0
      url_counts[topic] += 1
    end

    private def log_counts(_env : KEnv)
      puts "\nRequest counts: #{@request_counts}\n"
      puts "=" * 100
    end
  end
end
