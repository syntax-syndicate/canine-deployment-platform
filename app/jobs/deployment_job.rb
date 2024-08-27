require 'base64'
require 'json'

class DeploymentJob < ApplicationJob
  def perform(build)
    deployment = Deployment.create!(build: build)
    cluster_kubeconfig = deployment.project.cluster.kubeconfig
    project = deployment.project
    
    # Upload container registry secrets
    upload_registry_secrets(cluster_kubeconfig, project)
    
    deployment_yaml = K8::Stateless::Deployment.new(project).to_yaml
    service_yaml = K8::Stateless::Service.new(project).to_yaml
    apply_yaml_to_cluster(cluster_kubeconfig, deployment_yaml)
    apply_yaml_to_cluster(cluster_kubeconfig, service_yaml)
  end

  def apply_yaml_to_cluster(kubeconfig, yaml_content)
    # Assuming you have a method to run kubectl commands with the kubeconfig
    Tempfile.open(['kubeconfig', '.yaml']) do |kubeconfig_file|
      kubeconfig_file.write(kubeconfig.to_yaml)
      kubeconfig_file.flush

      # Create a temporary file for the YAML content
      Tempfile.open(['k8s', '.yaml']) do |yaml_file|
        yaml_file.write(yaml_content)
        yaml_file.flush

        # Apply the YAML file to the cluster using the kubeconfig file
        stdout, stderr, status = Open3.capture3("kubectl --kubeconfig=#{kubeconfig_file.path} apply -f #{yaml_file.path}")
        
        # Print the output and any errors to the console
        puts "\n\n=== kubectl apply output ==="
        puts stdout unless stdout.empty?
        puts stderr unless stderr.empty?
        puts "=== End of output ===\n"
        unless status.success?
          raise "Kubectl apply command failed: #{stderr}"
        end
      end
    end
  end

  def upload_registry_secrets(kubeconfig, project)
    docker_config_json = create_docker_config_json(project.user.github_username, project.user.github_access_token)
    secret_yaml = K8::Secrets::RegistrySecret.new(project, docker_config_json).to_yaml
    apply_yaml_to_cluster(kubeconfig, secret_yaml)
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