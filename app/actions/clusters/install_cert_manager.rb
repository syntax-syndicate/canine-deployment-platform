class Clusters::InstallCertManager
  extend LightService::Action

  expects :cluster

  executed do |context|
    cluster = context.cluster
    K8::Kubectl.new(cluster.kubeconfig).with_kube_config do |kubeconfig_file|
      cluster.info("Checking if cert manager is already installed")
      exit_status = Cli::RunAndLog.new(cluster).call(
        "kubectl get deployment ingress-nginx-controller",
        envs: {
          "KUBECONFIG" => kubeconfig_file.path,
        },
      )
      if exit_status.success?
        cluster.info("Cert manager is already installed")
        next
      end
      cluster.info("Cert manager not detected, installing...")

      envs = {
        "KUBECONFIG" => kubeconfig_file.path,
      }

      # Construct the command
      command = "bash #{Rails.root.join("resources", "k8", "scripts", "install_cert_manager.sh")}"
      exit_status = Cli::RunAndLog.new(cluster).call(command, envs: envs)
      if exit_status.success?
      else
        cluster.fail!
        context.fail!("Script failed with exit code #{exit_status.exitstatus}")
      end
    end
  end
end