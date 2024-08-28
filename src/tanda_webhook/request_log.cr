require "kemal"
require "json"

require "./helpers"
require "./types/webhook"

module Tanda::Webhook
  class RequestLog
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

    def record_webhook!(request : HTTP::Request, webhook : Types::Webhook)
      url = request.hostname.to_s
      topic = webhook.payload.topic

      @counts[TOTAL_COUNT_KEY][topic] += 1
      @counts[url][topic] += 1

      @requests << {headers: request.headers, body: webhook}
    end

    def log_counts
      Helpers.pretty_print_obj(REQUEST_COUNTS_STRING, @counts)
    end

    def empty? : Bool
      @counts.empty?
    end
  end
end
