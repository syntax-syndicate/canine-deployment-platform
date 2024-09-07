module InboundWebhooks
  class GithubController < ApplicationController
    skip_before_action :authenticate_user!
    before_action :verify_event

    def create
      # Save webhook to database
      record = InboundWebhook.create(body: payload)

      # Queue webhook for processing
      InboundWebhooks::GithubJob.perform_later(record)

      # Tell service we received the webhook successfully
      head :ok
    end

    private

    def verify_event
      payload = request.body.read
      # TODO: Verify the event was sent from the service
      # Render `head :bad_request` if verification fails
      secret = Jumpstart.credentials[:omniauth][:github][:webhook_secret]
      signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, payload)
      unless Rack::Utils.secure_compare(signature, request.headers['HTTP_X_HUB_SIGNATURE_256'])
        head :bad_request
      end
    end
  end
end
