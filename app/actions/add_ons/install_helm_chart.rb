class AddOns::InstallHelmChart
  extend LightService::Action
  expects :add_on

  executed do |context|
    add_on = context.add_on
    add_on.installing!
    charts = YAML.load_file(Rails.root.join('resources', 'helm', 'charts.yml'))['helm']['charts']
    chart = charts.find { |chart| chart['name'] == add_on.chart_type }
    # First, check if the chart is already installed & running
    client = K8::Helm::Client.new(add_on.cluster.kubeconfig, Cli::RunAndLog.new(add_on))
    charts = client.ls
    unless charts.any? { |chart| chart.name == add_on.name }
      charts = client.install(add_on.name, add_on.helm_chart_url)
    end
    add_on.installed!
  end
end