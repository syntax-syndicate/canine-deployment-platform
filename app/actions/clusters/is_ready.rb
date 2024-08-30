class Clusters::IsReady
  extend LightService::Action

  expects :cluster

  executed do |context|
    cluster = context.cluster
    client = K8::Client.new(cluster.kubeconfig)
    if client.can_connect?
      cluster.installing!
      cluster.append_log_line("Cluster is ready")
    else
      cluster.append_log_line("Cluster is not ready, retrying in 60 seconds...")
      context.fail!("Cluster is not ready")
    end
  end
end