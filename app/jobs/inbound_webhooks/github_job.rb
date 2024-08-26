module InboundWebhooks
  class GithubJob < ApplicationJob
    queue_as :default

    def perform(inbound_webhook)
      inbound_webhook.processing!

      # Process webhook
      # Determine the project
      # Trigger a docker build & docker deploy if auto deploy is on for the project
      body = JSON.parse(inbound_webhook.body)
      process_webhook(body)

      inbound_webhook.processed!

      # Or mark as failed and re-enqueue the job
      # inbound_webhook.failed!
    end

    def process_webhook(body)
      user = User.find_by(email: body['pusher']['email'])
      return if user.nil?
      projects = user.projects.where(repository_url: body['repository']['url'], branch: body['ref'], auto_deploy: true)
      projects.each do |project|
        # Trigger a docker build & docker deploy
        DeployJob.perform_later(project)
      end
    end
  end
end
