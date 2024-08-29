class Projects::Create
  extend LightService::Organizer

  def self.call(current_user, project)
    with(current_user:, project:).reduce(
      Projects::ValidateGithubRepository,
      Projects::Save,
      Projects::RegisterGithubWebhook,
    )
  end
end