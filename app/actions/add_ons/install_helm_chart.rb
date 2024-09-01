class AddOns::InstallHelmChart
  extend LightService::Action
  expects :add_on

  executed do |context|
    add_on = context.add_on
    K8::Kubectl.new(add_on.cluster.kubeconfig).with_kube_config do |kubeconfig_file|
      command = "helm install #{add_on.name} #{add_on.helm_chart_url}"
      exit_status = Cli::RunAndLog.new(add_on).call(command, envs: { "KUBECONFIG" => kubeconfig_file.path })
      if exit_status.success?
        add_on.installed!
      else
        add_on.failed!
        context.fail!("Script failed with exit code #{exit_status.exitstatus}")
      end
    end
  end
end