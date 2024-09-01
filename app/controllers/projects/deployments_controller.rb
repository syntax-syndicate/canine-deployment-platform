class Projects::DeploymentsController < Projects::BaseController
  before_action :set_project

  def index
    @builds = @project.builds
  end

  def redeploy
    deployment = @project.deployments.find(params[:id])
    new_build = deployment.build.dup
    new_build.save!
    BuildJob.perform_later(new_build.id)
    redirect_to project_deployment_path(project, new_build), notice: "Redeploying..."
  end

  def deploy
    result = Projects::DeployLatestCommit.execute(project: @project)
    if result.success?
      redirect_to @project, notice: "Deploying project..."
    else
      redirect_to @project, alert: "Failed to deploy project"
    end
  end
end