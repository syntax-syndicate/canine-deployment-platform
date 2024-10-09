class Clusters::MetricsController < Clusters::BaseController
  before_action :set_cluster
    include StorageHelper

  def show
    @pod_metrics = K8::Metrics::Pods.call(@cluster)
    @node_metrics = K8::Metrics::Nodes.call(@cluster)
    @metrics = @cluster.metrics
  end
end
