require "test_helper"

class InboundWebhooks::GithubControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  test "should return bad request if event verification fails" do
    # TODO: assert_response :bad_request
  end

  test "should return 200 OK if event verification succeeds" do
    # TODO: assert_response :ok
  end

  test "should create inbound webhook" do
    assert_difference "InboundWebhook.count" do
      post "/inbound_webhooks/github"
    end
  end

  test "should enqueue job" do
    post "/inbound_webhooks/github"
    assert_enqueued_jobs 1
  end
end
