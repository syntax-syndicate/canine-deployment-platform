module K8
  module Kubeconfig
    def with_kube_config
      Tempfile.open(['kubeconfig', '.yaml']) do |kubeconfig_file|
        kubeconfig_file.write(kubeconfig.to_yaml)
        kubeconfig_file.flush
        yield kubeconfig_file
      end
    end
  end
end