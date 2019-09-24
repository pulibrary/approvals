# frozen_string_literal: true
class AbsenceRequestsController < ApplicationController
  before_action :set_absence_request, only: [:show, :destroy]

  # GET /absence_requests/1
  # GET /absence_requests/1.json
  def show
    @absence_request = AbsenceRequestDecorator.new(@absence_request)
  end

  # GET /absence_requests/new
  def new
    @absence_request_change_set = absence_request_change_set
  end

  # GET /absence_requests/1/edit
  def edit
    @absence_request_change_set = absence_request_change_set

    # render the default
    return if @absence_request_change_set.model.pending?

    # handle the error
    respond_to do |format|
      @absence_request = absence_request_change_set.model
      format.html { redirect_to @absence_request, notice: "Absence can not be edited after it has been #{@absence_request_change_set.model.status}." }
      format.json { render :show, status: :invalid_edit, location: @absence_request }
    end
  end

  # GET /absence_requests/1/review
  def review
    @absence_request_change_set = absence_request_change_set
    allowed_to_review = @absence_request_change_set.model.only_supervisor(agent: current_staff_profile)

    # render the default
    return if @absence_request_change_set.model.pending? && allowed_to_review

    # handle the error
    respond_to do |format|
      @absence_request = absence_request_change_set.model
      message = if !allowed_to_review
                  "You are not allowed access to review this absence"
                else
                  "Absence can not be reviewed after it has been #{@absence_request_change_set.model.status}."
                end
      format.html { redirect_to @absence_request, notice: message }
      format.json { render :show, status: :invalid_edit, location: @absence_request }
    end
  end

  # POST /absence_requests
  # POST /absence_requests.json
  def create
    respond_to do |format|
      if absence_request_change_set.validate(processed_params) && absence_request_change_set.save
        @absence_request = absence_request_change_set.model
        format.html { redirect_to @absence_request, notice: "Absence request was successfully created." }
        format.json { render :show, status: :created, location: @absence_request }
      else
        copy_model_errors_to_change_set
        format.html { render :new }
        format.json { render json: absence_request_change_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /absence_requests/1
  # PATCH/PUT /absence_requests/1.json
  def update
    respond_to do |format|
      if absence_request_change_set.validate(processed_params) && absence_request_change_set.save
        @absence_request = absence_request_change_set.model
        format.html { redirect_to @absence_request, notice: "Absence request was successfully updated." }
        format.json { render :show, status: :ok, location: @absence_request }
      else
        copy_model_errors_to_change_set
        format.html { render :edit }
        format.json { render json: absence_request_change_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /absence_requests/1/approve
  # PATCH/PUT /absence_requests/1/approve.json
  def approve
    supervisor_action(action: :approve)
  end

  # PATCH/PUT /absence_requests/1/deny
  # PATCH/PUT /absence_requests/1/deny.json
  def deny
    supervisor_action(action: :deny)
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

    def absence_request_change_set
      @absence_request_change_set ||=
        if params[:id]
          AbsenceRequestChangeSet.new(AbsenceRequest.find(params[:id]))
        else
          AbsenceRequestChangeSet.new(AbsenceRequest.new)
        end
    end

    def copy_model_errors_to_change_set
      absence_request_change_set.model.errors.each do |key, value|
        @absence_request_change_set.errors.add(key, value)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def absence_request_params
      params.require(:absence_request).permit(:start_date, :end_date, :request_type, :absence_type, notes: [:content])
    end

    def processed_params
      local = absence_request_params.merge(creator_id: current_staff_profile.id)
      local[:notes] = process_notes(local[:notes])
      local
    end

    def process_notes(notes)
      return notes unless notes
      notes.map do |note_entry|
        note_entry.merge(creator_id: current_staff_profile.id) if note_entry[:content].present?
      end.compact
    end

    def supervisor_action(action:)
      allowed_to_change = can_change?(action: action)
      return unless allowed_to_change

      absence_request_change_set.model.aasm.fire(action, agent: current_staff_profile) if allowed_to_change
      respond_to do |format|
        if allowed_to_change && absence_request_change_set.validate(processed_params) && absence_request_change_set.save
          @absence_request = absence_request_change_set.model
          format.html { redirect_to @absence_request, notice: "Absence request was successfully #{@absence_request.status}." }
          format.json { render :show, status: :ok, location: @absence_request }
        else
          copy_model_errors_to_change_set
          format.html { render :review }
          format.json { render json: absence_request_change_set.errors, status: :unprocessable_entity }
        end
      end
    end

    def can_change?(action:)
      allowed_to_change = absence_request_change_set.model.only_supervisor(agent: current_staff_profile)
      return allowed_to_change if allowed_to_change

      respond_to do |format|
        @absence_request = absence_request_change_set.model
        format.html { redirect_to @absence_request, notice: "You are not allowed access to #{action} this absence" }
        format.json { render :show, status: :invalid_review, location: @absence_request }
      end
      allowed_to_change
    end
end
