require "colorize"
require "./tanda_webhook/**"

module Tanda::Webhook
  extend self

  VERSION = "0.1.0"

  def main
    secret = ask_for_secret
    run_server(secret)
  end

  private def ask_for_secret : String?
    puts "Enter secret (security token)".colorize.white.bold
    puts "This is used to verify that the request is coming from Tanda (leave blank to not check)\n".colorize.white.bold

    gets.try(&.chomp).presence
  end

  private def run_server(secret : String?)
    {% if flag?(:release) %}
      # Release mode
      # By running `./scripts/build/release.sh` && `./bin/tanda-webhook`
      Kemal.config.env = "production"
    {% end %}

    Tanda::Webhook::Server.run(secret)
  end
end

Tanda::Webhook.main
