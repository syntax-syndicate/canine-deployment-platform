class K8::Helm::Service
  attr_reader :add_on, :client

  def initialize(add_on)
    @add_on = add_on
    @client = K8::Client.new(add_on.cluster.kubeconfig).client
  end
end