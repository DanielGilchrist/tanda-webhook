require "./tanda_webhook/**"

module Tanda::Webhook
  extend self

  VERSION = "0.1.0"

  def main
    Kemal.config.env = begin
      {% if flag?(:debug) %}
        # Development mode
        # By running `crystal run ./src/tanda_webhook.cr`
        "development"
      {% else %}
        # Release mode
        # By running `./scripts/build/release.sh`
        # or
        # ./bin/tanda-webhook
        "production"
      {% end %}
    end

    Tanda::Webhook::Server.run
  end
end

Tanda::Webhook.main
