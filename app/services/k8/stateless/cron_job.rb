class K8::Stateless::CronJob
  def initialize(project)
    @project = project
  end

  def create
    K8::Stateless::CronJob.new(@project).create
  end
end