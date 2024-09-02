class Projects::EnvironmentVariablesController < Projects::BaseController
  before_action :set_project

  def index
    @environment_variables = @project.environment_variables
  end

  def create
    @project.environment_variables.create!(environment_variable_params)
    # reapply deployment.yaml
  end

  def update
    environment_variable = @project.environment_variables.find(params[:id])
    environment_variable.update!(environment_variable_params)
  end

  private
  def environment_variable_params
    params.require(:environment_variable).permit(:name, :value)
  end
end