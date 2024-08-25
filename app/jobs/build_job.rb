class BuildJob < ApplicationJob
  queue_as :default

  def perform(project)
    # Ensure the project is loaded as an instance of the Project model
    project = Project.find(project.id)

    # Step 1: Run any predeploy commands if provided
    if project.predeploy_command.present?
      Rails.logger.info "Running predeploy command: #{project.predeploy_command}"
      success = system(project.predeploy_command)
      
      unless success
        Rails.logger.error "Predeploy command failed for project #{project.name}"
        return
      end
    end

    # Step 2: Construct the Docker build command
    docker_build_command = [
      "docker", "build",
      "-t", "#{project.user.docker_hub_username}/#{project.name.downcase}:latest",
      "-f", project.dockerfile_path,
      project.docker_build_context_directory
    ]

    # Step 3: Execute the Docker build command
    Rails.logger.info "Running Docker build command: #{docker_build_command.join(' ')}"
    stdout, stderr, status = Open3.capture3(*docker_build_command)

    if status.success?
      Rails.logger.info "Docker build completed successfully for project #{project.name}:\n#{stdout}"
    else
      Rails.logger.error "Docker build failed for project #{project.name} with error:\n#{stderr}"
      return
    end

    # Step 4: Log in to Docker Hub
    docker_login_command = [
      "docker", "login",
      "--username", project.user.docker_hub_username,
      "--password", project.user.docker_hub_access_token
    ]

    Rails.logger.info "Logging into Docker Hub as #{project.user.docker_hub_username}"
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
      "#{project.user.docker_hub_username}/#{project.name.downcase}:latest"
    ]

    Rails.logger.info "Pushing Docker image to Docker Hub: #{docker_push_command.join(' ')}"
    stdout, stderr, status = Open3.capture3(*docker_push_command)

    if status.success?
      Rails.logger.info "Docker image pushed successfully for project #{project.name}:\n#{stdout}"
    else
      Rails.logger.error "Docker push failed for project #{project.name} with error:\n#{stderr}"
      return
    end

    # Step 6: Optionally, add post-deploy tasks or notifications
  end
end
