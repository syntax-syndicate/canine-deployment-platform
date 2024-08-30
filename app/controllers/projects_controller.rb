class ProjectsController < ApplicationController
  include ProjectsHelper
  before_action :set_project, only: [:show, :edit, :update, :destroy, :deploy]

  # GET /projects
  def index
    @pagy, @projects = pagy(Project.sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @projects
  end

  # GET /projects/1 or /projects/1.json
  def show
  end

  def deploy
    build = Build.create!(project: @project)
    deploy = Deploy.create!(project: @project, build:)
    DeployJob.perform_later(deploy)
    redirect_to @project, notice: "Deploying project"
  end

  # GET /projects/new
  def new
    @project = Project.new

    # Uncomment to authorize with Pundit
    # authorize @project
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects or /projects.json
  def create
    result = Projects::Create.call(Project.new(project_params))

    @project = result.project
    respond_to do |format|
      if result.success?
        format.html { redirect_to @project, notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    @project.destroy!
    respond_to do |format|
      format.html { redirect_to projects_url, status: :see_other, notice: "Project was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_project
    @project = Project.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @project
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path
  end

  # Only allow a list of trusted parameters through.
  def project_params
    params.require(:project).permit(
      :name,
      :repository_url,
      :branch,
      :cluster_id,
      :container_registry,
      :docker_build_context_directory,
      :docker_command,
      :dockerfile_path,
      :project_type,
    )
  end
end
