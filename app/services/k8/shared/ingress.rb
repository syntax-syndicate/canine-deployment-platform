class K8::Shared::Ingress < K8::Base
  attr_accessor :cluster_name, :domains

  def initialize(cluster)
    @cluster = cluster
    @domains = cluster.domains
  end
end