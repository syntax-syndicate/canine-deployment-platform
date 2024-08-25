class DeployJob < ApplicationJob
  def perform(project)
    cluster_kubeconfig = project.cluster.kubeconfig
    deployment_yaml = K8::Stateless::Deployment.new(project).to_yaml
    service_yaml = K8::Stateless::Service.new(project).to_yaml
    apply_yaml_to_cluster(cluster_kubeconfig, deployment_yaml)
    apply_yaml_to_cluster(cluster_kubeconfig, service_yaml)
  end

  def apply_yaml_to_cluster(kubeconfig, yaml_content)
    # Assuming you have a method to run kubectl commands with the kubeconfig
    Tempfile.open(['kubeconfig', '.yaml']) do |kubeconfig_file|
      kubeconfig_file.write(kubeconfig)
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
end