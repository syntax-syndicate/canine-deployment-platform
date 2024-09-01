class Clusters::InstallMetricServer
  include LightService::Action

  expects :cluster

  executed do |context|
    cluster = context.cluster
    K8::Kubectl.new(cluster.kubeconfig).with_kube_config do |kubeconfig_file|
      # Check if metric server is already installed
      exit_status = Cli::RunAndLog.new(cluster).call(
        "kubectl get deployment metrics-server -n kube-system",
        envs: {
          "KUBECONFIG" => kubeconfig_file.path,
        },
      )
      if exit_status.success?
        next
      end
      exit_status = Cli::RunAndLog.new(cluster).call(
        "kubectl apply -f #{Rails.root.join('resources', 'k8', 'shared', 'metrics_server.yaml')}",
        envs: {
          "KUBECONFIG" => kubeconfig_file.path,
        },
      )
      if exit_status.success?
        cluster.info("Metric server installed")
      else
        cluster.fail!
        cluster.info("Metric server failed to install")
        context.fail!("Failed to install metric server")
      end
    end
  end
end