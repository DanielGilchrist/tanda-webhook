require "./spec_helper"

describe Tanda::Webhook do
  it "Returns 204" do
    headers, body = valid_headers_and_body
    post "/", headers, body

    response.status_code.should eq 204
  end
end
