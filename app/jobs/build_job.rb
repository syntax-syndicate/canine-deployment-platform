class BuildJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    # Ensure the project is loaded as an instance of the Project model
    build = Build.create!(project_id:)
    project = Project.find(project_id)

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
    Dir.mktmpdir do |repository_path|
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
        "-t", "ghcr.io/#{project.repository_url}:latest",
        "-f", File.join(repository_path, project.dockerfile_path),
        File.join(repository_path, project.docker_build_context_directory)
      ]

      # Step 4: Execute the Docker build command
      build.append_log_line "Running Docker build command: #{docker_build_command.join(' ')}"
      IO.popen(docker_build_command, "r") do |io|
        # Continuously read each line of output
        io.each do |line|
          # Print the line to the console
          build.append_log_line line
        end

        io.close
        exit_status = $?.exitstatus
      
        if exit_status != 0
          build.append_log_line "Command failed with exit status #{exit_status}"
        else
          build.append_log_line "Command completed successfully."
        end
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

      # Step 6: Push the Docker image to Docker Hub
      docker_push_command = [
        "docker", "push",
        "ghcr.io/#{project.repository_url}:latest",
      ]

      build.append_log_line "Pushing Docker image to Docker Hub: #{docker_push_command.join(' ')}"
      stdout, stderr, status = Open3.capture3(*docker_push_command)

      if status.success?
        build.append_log_line "Docker image pushed successfully for project #{project.name}:\n#{stdout}"
      else
        build.append_log_line "Docker push failed for project #{project.name} with error:\n#{stderr}"
        return
      end

      build.completed!
      # Step 7: Optionally, add post-deploy tasks or slack notifications
    rescue StandardError => e
      build.append_log_line "Build failed: #{e.message}"
      build.failed!
    end
  end
end
