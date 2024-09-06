class Clusters::InstallAcmeIssuer
  extend LightService::Action

  expects :cluster

  executed do |context|
    cluster = context.cluster
    K8::Kubectl.new(cluster.kubeconfig).with_kube_config do |kubeconfig_file|
      cluster.info("Checking if acme issuer is already installed")
      exit_status = Cli::RunAndLog.new(cluster).call(
        "kubectl get issuer",
        envs: {
          "KUBECONFIG" => kubeconfig_file.path,
        },
      )
      if exit_status.success?
        cluster.info("Acme issuer is already installed")
        next
      end
    end

    kubectl = K8::Kubectl.new(cluster.kubeconfig)
    cluster.info("Acme issuer not detected, installing...")
    ingress_yaml = K8::Shared::AcmeIssuer.new(cluster.user.email).to_yaml
    kubectl.apply_yaml(ingress_yaml) do |command|
      exit_status = Cli::RunAndLog.new(cluster).call(command)
      if exit_status.success?
        cluster.info("Acme issuer installed")
      else
        cluster.failed!
        cluster.info("Acme issuer failed to install")
        context.fail!("Script failed with exit code #{exit_status.exitstatus}")
      end
    end
  end
end