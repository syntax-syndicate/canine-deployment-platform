# frozen_string_literal: true

class K8::Stateless::Deployment < K8::Base
  attr_accessor :name, :port, :environment_variables, :container_registry_url, :service_command

  def initialize(service)
    super
    project = service.project
    @name = project.name
    @port = 3000
    @environment_variables = project.environment_variables
    @container_registry_url = project.container_registry_url
    @service_command = service.command
  end
end
