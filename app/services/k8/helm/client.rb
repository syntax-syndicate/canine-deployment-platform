class K8::Helm::Client
  attr_reader :kubeconfig
  def initialize(kubeconfig)
    @kubeconfig = kubeconfig
  end
end