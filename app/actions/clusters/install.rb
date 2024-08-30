class Clusters::Install
  extend LightService::Organizer

  def self.call(cluster)
    with(cluster:).reduce(
      Clusters::IsReady,
      Clusters::InstallCertManager,
    )
  end
end