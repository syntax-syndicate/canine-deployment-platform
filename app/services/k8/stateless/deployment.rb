class K8::Stateless::Deployment < K8::Base
  attr_accessor :project, :name, :container_registry, :port, :environment_variables

  def initialize(project)
    @project = project
    @name = project.name
    @container_registry = project.container_registry
    @port = 3000
    @environment_variables = project.environment_variables
  end
end