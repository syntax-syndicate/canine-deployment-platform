class K8::Helm::Postgresql < K8::Helm::Service
  def service_name
    "#{add_on.name}-postgresql"
  end

  def internal_url
    service = client.get_services(namespace: 'default').find do |service|
      service.metadata.name == service_name
    end
    "postgresql://#{username}:#{password}@#{service.metadata.name}.#{service.metadata.namespace}.svc.cluster.local:#{service.spec.ports[0].port}/#{database}"
  end

  def has_external_url?
    false
  end

  protected
  def database
  end

  def username
  end

  def password
  end
end