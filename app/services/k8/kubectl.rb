class K8::Kubectl
  attr_reader :kubeconfig, :runner
  def initialize(kubeconfig, runner)
    @kubeconfig = kubeconfig
    @runner = runner
  end

  def self.from_project(project)
    new(project.cluster.kubeconfig)
  end

  def with_kube_config
    Tempfile.open(['kubeconfig', '.yaml']) do |kubeconfig_file|
      kubeconfig_file.write(kubeconfig.to_yaml)
      kubeconfig_file.flush
      yield kubeconfig_file
    end
  end

  def apply_yaml(yaml_content)
    with_kube_config do |kubeconfig_file|
      # Create a temporary file for the YAML content
      Tempfile.open(['k8s', '.yaml']) do |yaml_file|
        yaml_file.write(yaml_content)
        yaml_file.flush

        # Apply the YAML file to the cluster using the kubeconfig file
        command = "kubectl --kubeconfig=#{kubeconfig_file.path} apply -f #{yaml_file.path}"
        runner.(command)
      end
    end
  end

  def call(command)
    with_kube_config do |kubeconfig_file|
      full_command = "kubectl --kubeconfig=#{kubeconfig_file.path} #{command}"
      runner.(full_command)
    end
  end
end
