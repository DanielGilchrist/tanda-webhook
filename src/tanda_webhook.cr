require "./tanda_webhook/**"

module Tanda::Webhook
  extend self

  VERSION = "0.1.0"

  def main
    Kemal.config.env = {% if flag?(:debug) %}
      "development"
    {% else %}
      "production"
    {% end %}

    Tanda::Webhook::Server.run
  end
end

Tanda::Webhook.main
