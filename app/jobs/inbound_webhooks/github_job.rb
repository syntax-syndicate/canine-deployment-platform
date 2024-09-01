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
      return if body['pusher'].nil?
      user = User.find_by(email: body['pusher']['email'])
      return if user.nil?
      branch = body['ref'].gsub('refs/heads/', '')
      projects = user.projects.where(repository_url: body['repository']['full_name'], branch: branch, auto_deploy: true)
      projects.each do |project|
        # Trigger a docker build & docker deploy
        if project.auto_deploy
          build = Build.create!(
            project_id: project.id,
            commit_sha: body['head_commit']['id'],
            commit_message: body['head_commit']['message']
          )
          BuildJob.perform_later(build.id)
        end
      end
    end
  end
end
