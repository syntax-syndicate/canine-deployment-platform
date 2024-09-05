require 'base64'
require 'json'

class Projects::DeploymentJob < ApplicationJob
  def perform(deployment)
    cluster_kubeconfig = deployment.project.cluster.kubeconfig
    project = deployment.project
    
    # Upload container registry secrets
    kubectl = K8::Kubectl.new(cluster_kubeconfig)
    upload_registry_secrets(kubectl, deployment)
    
    deployment_yaml = K8::Stateless::Deployment.new(project).to_yaml
    kubectl.apply_yaml(deployment_yaml) do |command|
      Cli::RunAndLog.new(deployment).call(command)
    end

    unless project.background_service?
      service_yaml = K8::Stateless::Service.new(project).to_yaml
      kubectl.apply_yaml(service_yaml) do |command|
      Cli::RunAndLog.new(deployment).call(command)
    end

    if project.web_service?
      # TODO: Set up ingress
    end

    deployment.completed!
  rescue StandardError => e
    deployment.info "Deployment failed: #{e.message}"
    deployment.failed!
  end

  def upload_registry_secrets(kubectl, deployment)
    project = deployment.project
    docker_config_json = create_docker_config_json(project.user.github_username, project.user.github_access_token)
    secret_yaml = K8::Secrets::RegistrySecret.new(project, docker_config_json).to_yaml
    kubectl.apply_yaml(secret_yaml) do |command|
      Cli::RunAndLog.new(deployment).call(command)
    end
  end

  def create_docker_config_json(username, password)
    # First base64 encoding
    auth_value = Base64.strict_encode64("#{username}:#{password}")

    # Create the JSON structure
    docker_config = {
      "auths" => {
        "ghcr.io" => {
          "auth" => auth_value
        }
      }
    }

    # Second base64 encoding of the entire JSON
    Base64.strict_encode64(JSON.generate(docker_config))
  end
end