class Projects::DomainsController < Projects::BaseController
  before_action :set_project

  def index
    @domains = @project.domains
  end

  def create
    @domain = @project.domains.new(domain_params)
    if @domain.save
      Projects::AddDomainJob.perform_later(@domain)
      redirect_to project_path(@project), notice: 'Domain was successfully added.'
    else
      render :new
    end
  end

  def destroy
    @domain = @project.domains.find(params[:id])
    @domain.destroy
    redirect_to project_path(@project), notice: 'Domain was successfully removed.'
  end

  private
  def domain_params
    params.require(:domain).permit(:domain_name)
  end
end