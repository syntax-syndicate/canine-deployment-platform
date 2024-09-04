class Projects::DomainsController < Projects::BaseController
  before_action :set_project

  def create
    @domain = @project.domains.new(domain_params)
    respond_to do |format|
      if @domain.save
        Projects::AddDomainJob.perform_later(@domain.cluster)
        format.html { redirect_to project_path(@project), notice: 'Domain was successfully added.' }
        format.json { render :show, status: :created, domain: @domain }
        format.turbo_stream
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  def destroy
    @domain = @project.domains.find(params[:id])
    @domain.destroy

    respond_to do |format|
      format.turbo_stream
    end
  end

  private
  def domain_params
    params.require(:domain).permit(:domain_name)
  end
end