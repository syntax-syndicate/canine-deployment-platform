class Projects::AddDomainJob < ApplicationJob
  def perform(cluster)
    K8::Kubectl.new(cluster.kubeconfig).apply_yaml(K8::Shared::Ingress.new(cluster).to_yaml) do |command|
      Cli::RunAndLog.new(cluster).call(command)
    end
  end
end