class K8::Kubectl
  attr_reader :kubeconfig
  def initialize(kubeconfig)
    @kubeconfig = kubeconfig
  end

  def self.from_project(project)
    new(project.cluster.kubeconfig)
  end

  def run(command)
    Tempfile.open(['kubeconfig', '.yaml']) do |kubeconfig_file|
      kubeconfig_file.write(kubeconfig.to_yaml)
      kubeconfig_file.flush
      full_command = "kubectl --kubeconfig=#{kubeconfig_file.path} #{command}"
      Rails.logger.info("Running command: #{full_command}")
      stdout, stderr, status = Open3.capture3(full_command)
      return stdout, stderr, status
    end
  end
end
