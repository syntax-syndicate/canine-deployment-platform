class AddOnsController < ApplicationController
  before_action :set_add_on, only: [:show, :edit, :update, :destroy]

  # GET /add_ons
  def index
    @pagy, @add_ons = pagy(AddOn.sort_by_params(params[:sort], sort_direction))

    # Uncomment to authorize with Pundit
    # authorize @add_ons
  end

  # GET /add_ons/1 or /add_ons/1.json
  def show
  end

  # GET /add_ons/new
  def new
    @add_on = AddOn.new

    # Uncomment to authorize with Pundit
    # authorize @add_on
  end

  # GET /add_ons/1/edit
  def edit
  end

  # POST /add_ons or /add_ons.json
  def create
    if add_on_params[:add_on_type] == "postgres" || add_on_params[:add_on_type] == "redis"
      @add_on = DatabaseAddOn.make(add_on_params)
    else
      @add_on = AddOn.create(add_on_params)
    end

    # Uncomment to authorize with Pundit
    # authorize @add_on

    respond_to do |format|
      if @add_on.save
        format.html { redirect_to @add_on, notice: "Add on was successfully created." }
        format.json { render :show, status: :created, location: @add_on }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @add_on.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /add_ons/1 or /add_ons/1.json
  def update
    respond_to do |format|
      if @add_on.update(add_on_params)
        format.html { redirect_to @add_on, notice: "Add on was successfully updated." }
        format.json { render :show, status: :ok, location: @add_on }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @add_on.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /add_ons/1 or /add_ons/1.json
  def destroy
    @add_on.destroy!
    respond_to do |format|
      format.html { redirect_to add_ons_url, status: :see_other, notice: "Add on was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_add_on
    @add_on = AddOn.find(params[:id])

    # Uncomment to authorize with Pundit
    # authorize @add_on
  rescue ActiveRecord::RecordNotFound
    redirect_to add_ons_path
  end

  # Only allow a list of trusted parameters through.
  def add_on_params
    params.require(:add_on).permit(:cluster_id, :add_on_type, :name, :metadata)

    # Uncomment to use Pundit permitted attributes
    # params.require(:add_on).permit(policy(@add_on).permitted_attributes)
  end
end
