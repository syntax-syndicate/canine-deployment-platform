class InstallClusterJob < ApplicationJob
  queue_as :default

  def perform(cluster)
    Cluster.install(cluster)
  end
end