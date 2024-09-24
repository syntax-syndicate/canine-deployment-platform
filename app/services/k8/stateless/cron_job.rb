# frozen_string_literal: true

class K8::Stateless::CronJob < K8::Base
  attr_accessor :name, :schedule, :project_name, :service_command, :container_registry_url

  def initialize(service)
    super
    @name = service.name
    @schedule = service.cron_schedule.schedule
    @project_name = service.project.name
    @container_registry_url = service.project.container_registry_url
    @service_command = service.command
  end
end
