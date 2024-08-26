class Github::RegisterWebhook
  include Rails.application.routes.url_helpers
  def register_github_webhook(user, repo)
    client = Octokit::Client.new(access_token: user.github_token)
    client.create_hook(
      repo,
      'web',
      {
        url: inbound_webhooks_github_index_url,
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