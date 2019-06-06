class StateChangesController < ApplicationController
  before_action :set_state_change, only: [:show, :edit, :update, :destroy]

  # GET /state_changes
  # GET /state_changes.json
  def index
    @state_changes = StateChange.all
  end

  # GET /state_changes/1
  # GET /state_changes/1.json
  def show; end

  # GET /state_changes/new
  def new
    @state_change = StateChange.new
  end

  # GET /state_changes/1/edit
  def edit; end

  # POST /state_changes
  # POST /state_changes.json
  def create
    @state_change = StateChange.new(state_change_params)

    respond_to do |format|
      if @state_change.save
        format.html { redirect_to @state_change, notice: "StateChange was successfully created." }
        format.json { render :show, status: :created, location: @state_change }
      else
        format.html { render :new }
        format.json { render json: @state_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /state_changes/1
  # PATCH/PUT /state_changes/1.json
  def update
    respond_to do |format|
      if @state_change.update(state_change_params)
        format.html { redirect_to @state_change, notice: "StateChange was successfully updated." }
        format.json { render :show, status: :ok, location: @state_change }
      else
        format.html { render :edit }
        format.json { render json: @state_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /state_changes/1
  # DELETE /state_changes/1.json
  def destroy
    @state_change.destroy
    respond_to do |format|
      format.html { redirect_to state_changes_url, notice: "StateChange was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_state_change
      @state_change = StateChange.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def state_change_params
      params.require(:state_change).permit(:approver_id, :request_id, :action,
                                           request_attributes: [
                                             :id,
                                             :travel_category,
                                             notes_attributes: [:creator_id, :content],
                                             event_requests_attributes: [:id, :recurring_event_id]
                                           ])
    end
end
