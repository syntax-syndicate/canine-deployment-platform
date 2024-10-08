namespace :kube do
  desc "Poll Kubernetes cluster metrics"
  task metrics: :environment do
    # Set up the Kubernetes client
    Cluster.running.each do |cluster|
      nodes = K8::Metrics::Nodes.call(cluster)
      attributes = nodes.flat_map do |node|
        [
          {
            metric_type: :cpu,
            tags: [ node[:name] ],
            metadata: {
              cpu_cores: node[:cpu_cores],
              cpu_percent: node[:cpu_percent]
            }
          },
          {
            metric_type: :memory,
            tags: [ node[:name] ],
            metadata: {
              memory_bytes: node[:memory_bytes],
              memory_percent: node[:memory_percent]
            }
          }
        ]
      end

      cluster.metrics.create(attributes)
    end
  end
end
