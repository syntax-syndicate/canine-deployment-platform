class Projects::Create
  extend LightService::Action

  expects :current_user, :project
  promises :project

  executed do
    client = Octokit::Client.new(access_token: context.current_user.github_token)
    client.create_hook(
      context.project.repository_url,
      'web',
      {
        url: Rails.application.routes.url_helpers.inbound_webhooks_github_index_url,
        content_type: 'json',
        secret: Jumpstart.credentials[:omniauth][:github][:webhook_secret]
      },
      {
        events: ['push'],
        active: true
      }
    )
  end
end