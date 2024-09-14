class K8::Helm::Redis < K8::Helm::Service
  def service_name
    "#{add_on.name}-redis-master"
  end

  def internal_url
    service = client.get_services(namespace: 'default').find do |service|
      service.metadata.name == service_name
    end
    "redis://#{service.metadata.name}.#{service.metadata.namespace}.svc.cluster.local:#{service.spec.ports[0].port}"
  end

  def has_external_url?
    false
  end

  protected

  def password
  end
end