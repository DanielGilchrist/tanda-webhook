require "json"

module Tanda::Webhook
  module Types
    class WebhookPayload
      include JSON::Serializable

      getter body : JSON::Any
      getter topic : String
      getter organisation_id : String
    end
  end
end
