require "spec"
require "spec-kemal"

Kemal.config.always_rescue = false

def valid_headers_and_body
  headers = HTTP::Headers{
    "Host" => "somedummytesturl@test.com",
    "User-Agent" => "tanda-webhooks",
    "Content-Length" => "597",
    "Accept" => "*/*",
    "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
    "Content-Type" => "application/json",
    "X-Forwarded-For" => "1.11.111.11",
    "X-Forwarded-Host" => "somedummytesturl@test.com",
    "X-Forwarded-Proto" => "https",
    "X-Hook-Signature" => "73480d2bc456d4bdaf841b2d5a940691fe4468c5",
    "X-Request-Id" => "f9510897-2532-4ad7-b106-eea63ef6b6ac"
  }

  body = %({
    "hook_key": "2b2bd799-a8b8-4461-a4bc-21dc5cde1385",
    "hook_time": 1704280102,
    "hook_signature": "tandawebhooktest",
    "payload": {
      "body": {
        "id": 20722136,
        "start": 1704099600,
        "breaks": [],
        "finish": 1704128400,
        "user_id": 74548,
        "record_id": null,
        "roster_id": 207102,
        "time_zone": "Europe/London",
        "updated_at": 0,
        "utc_offset": 0,
        "department_id": null,
        "creation_method": "manual",
        "shift_detail_id": null,
        "needs_acceptance": false,
        "acceptance_status": "not_accepted",
        "creation_platform": "web",
        "last_published_at": null,
        "last_acknowledged_at": null,
        "automatic_break_length": 30
      },
      "topic": "schedule.destroyed",
      "organisation_id": "796"
    }
  })

  {headers, body}
end

require "../src/tanda_webhook"
