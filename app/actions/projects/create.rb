class Projects::Create
  extend LightService::Organizer

  def self.call(project)
    with(project:).reduce(
      Projects::ValidateGithubRepository,
      Projects::Save,
      Projects::RegisterGithubWebhook,
    )
  end
end