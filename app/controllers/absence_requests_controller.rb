class AbsenceRequestsController < ApplicationController
  before_action :set_absence_request, only: [:show, :edit, :update, :destroy]

  # GET /absence_requests
  # GET /absence_requests.json
  def index
    @absence_requests = AbsenceRequest.all
  end

  # GET /absence_requests/1
  # GET /absence_requests/1.json
  def show; end

  # GET /absence_requests/new
  def new
    @absence_request = AbsenceRequest.new
  end

  # GET /absence_requests/1/edit
  def edit; end

  # POST /absence_requests
  # POST /absence_requests.json
  def create
    @absence_request = AbsenceRequest.new(absence_request_params)

    respond_to do |format|
      if @absence_request.save
        format.html { redirect_to @absence_request, notice: "Absence request was successfully created." }
        format.json { render :show, status: :created, location: @absence_request }
      else
        format.html { render :new }
        format.json { render json: @absence_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /absence_requests/1
  # PATCH/PUT /absence_requests/1.json
  def update
    respond_to do |format|
      if @absence_request.update(absence_request_params)
        format.html { redirect_to @absence_request, notice: "Absence request was successfully updated." }
        format.json { render :show, status: :ok, location: @absence_request }
      else
        format.html { render :edit }
        format.json { render json: @absence_request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /absence_requests/1
  # DELETE /absence_requests/1.json
  def destroy
    @absence_request.destroy
    respond_to do |format|
      format.html { redirect_to absence_requests_url, notice: "Absence request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_absence_request
      @absence_request = AbsenceRequest.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def absence_request_params
      params.require(:absence_request).permit(:creator_id, notes_attributes: [:creator_id, :content])
    end
end
