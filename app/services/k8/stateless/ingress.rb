class K8::Stateless::Ingress < K8::Base
  attr_accessor :project, :domains

  def initialize(project)
    @project = project
    @domains = project.domains
  end
end