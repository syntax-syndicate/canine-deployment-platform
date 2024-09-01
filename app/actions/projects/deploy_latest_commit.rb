class Projects::DeployLatestCommit
  extend LightService::Action

  expects :project
  promises :project

  executed do |context|
    # Fetch the latest commit from the default branch
    client = Octokit::Client.new(access_token: project.user.github_access_token)
    commit = client.commits(project.repository_url).first

    build = Build.create!(
      project: context.project,
      commit_sha: commit.sha,
      commit_message: commit.commit[:message]
    )
    BuildJob.perform_later(build.id)
  end
end