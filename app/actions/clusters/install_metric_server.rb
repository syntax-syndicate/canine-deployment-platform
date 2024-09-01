class Clusters::InstallMetricServer
  include LightService::Action

  expects :cluster

  executed do |context|
    cluster = context.cluster
    K8::Kubectl.with_kubeconfig(cluster.kubeconfig) do |kubeconfig_file|
      exit_status = Cli::RunAndLog.new(cluster).call(
        "kubectl apply -f #{Rails.root.join('resources', 'k8', 'shared', 'metrics_server.yaml')}",
        env: {
          "KUBECONFIG" => kubeconfig_file.path,
        },
      )
      if exit_status.success?

      else
        cluster.fail!
        context.fail!("Failed to install metric server")
      end
    end
  end
end