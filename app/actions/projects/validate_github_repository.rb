class Projects::Create
  extend LightService::Action

  expects :current_user, :project
  promises :project

  executed do
    client = Octokit::Client.new(access_token: context.current_user.github_token)
    unless client.repository?(context.project.repository_url)
      context.project.errors.add(:repository_url, "does not exist")
      context.fail!("Repository does not exist")
    end
  end
end