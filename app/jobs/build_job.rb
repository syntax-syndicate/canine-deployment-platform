class BuildJob < ApplicationJob
  queue_as :default

  def perform(project)
    # Ensure the project is loaded as an instance of the Project model
    build = Build.create(project:)
    project = Project.find(project.id)

    # Step 1: Run any predeploy commands if provided
    if project.predeploy_command.present?
      build.append_log_line "Running predeploy command: #{project.predeploy_command}"
      success = system(project.predeploy_command)
      
      unless success
        build.append_log_line "Predeploy command failed for project #{project.name}"
        return
      end
    end
    # Step 2: clone the repository to a temporary directory with github credentials
    TmpDir.create do |dir|
      repository_path = dir.path
      build.append_log_line("Cloning repository: #{project.repository_url} to #{repository_path}")

      # Ensure the temporary directory doesn't exist
      FileUtils.rm_rf(repository_path) if Dir.exist?(repository_path)
      
      # Construct the git clone command with OAuth token
      git_clone_command = [
        "git",
        "clone",
        "https://#{project.user.github_username}:#{project.user.github_access_token}@github.com/#{project.repository_url}.git",
        repository_path
      ]
      
      # Execute the git clone command
      stdout, stderr, status = Open3.capture3(*git_clone_command)
      
      if status.success?
        build.append_log_line "Repository cloned successfully to #{repository_path}"
      else
        build.append_log_line "Failed to clone repository: #{stderr}"
        return
      end

      # Step 3: Construct the Docker build command
      docker_build_command = [
        "docker", "build",
        "-t", "#{project.user.github_username}/#{project.repository_name.downcase}:latest",
        "-f", project.dockerfile_path,
        project.docker_build_context_directory
      ]

      # Step 4: Execute the Docker build command
      Rails.logger.info "Running Docker build command: #{docker_build_command.join(' ')}"
      stdout, stderr, status = Open3.capture3(*docker_build_command)

      if status.success?
        Rails.logger.info "Docker build completed successfully for project #{project.name}:\n#{stdout}"
      else
        Rails.logger.error "Docker build failed for project #{project.name} with error:\n#{stderr}"
        return
      end

      # Step 5: Log in to Docker Hub
      docker_login_command = [
        "docker",
        "login",
        "ghcr.io",
        "--username", project.user.github_username,
        "--password", project.user.github_access_token,
      ]

      Rails.logger.info "Logging into Docker Hub as #{project.user.github_username}"
      stdout, stderr, status = Open3.capture3(*docker_login_command)

      if status.success?
        Rails.logger.info "Logged in to Docker Hub successfully."
      else
        Rails.logger.error "Docker Hub login failed with error:\n#{stderr}"
        return
      end

      # Step 5: Push the Docker image to Docker Hub
      docker_push_command = [
        "docker", "push",
        "#{project.user.github_username}/#{project.name.downcase}:latest"
      ]

      Rails.logger.info "Pushing Docker image to Docker Hub: #{docker_push_command.join(' ')}"
      stdout, stderr, status = Open3.capture3(*docker_push_command)

      if status.success?
        Rails.logger.info "Docker image pushed successfully for project #{project.name}:\n#{stdout}"
      else
        Rails.logger.error "Docker push failed for project #{project.name} with error:\n#{stderr}"
        return
      end

      # Step 6: Optionally, add post-deploy tasks or slack notifications
    end
  end
end
