require "./server"

module Tanda::Webhook
  extend self

  VERSION = "0.1.0"

  def main
    Tanda::Webhook::Server.run!
  end
end

Tanda::Webhook.main
