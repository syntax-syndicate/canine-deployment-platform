class Projects::ShellsController < Projects::BaseController
  before_action :set_project
  def show
    # Open a TTY
  end

  private
  def set_project
    @project = current_user.projects.find(params[:project_id])
  end
end