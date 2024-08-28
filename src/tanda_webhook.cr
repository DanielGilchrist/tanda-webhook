require "kemal"

require "./tanda_webhook/server"

module Tanda::Webhook
  extend self

  VERSION = "0.1.0"

  def main
    {% if flag?(:release) %}
      # Release mode
      # By running `./scripts/build/release.sh` && `./bin/tanda-webhook`
      Kemal.config.env = "production"
    {% end %}

    Kemal.config.app_name = "tanda webhook"

    Tanda::Webhook::Server.run
  end
end

Tanda::Webhook.main
