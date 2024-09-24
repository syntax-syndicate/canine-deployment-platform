class K8::Stateless::Ingress < K8::Base
  attr_accessor :name, :domains

  def initialize(service)
    @name = service.project.name
    @domains = service.domains
  end
end
