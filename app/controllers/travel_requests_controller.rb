# frozen_string_literal: true
class TravelRequestsController < ApplicationController
  before_action :set_travel_request, only: [:show, :update, :destroy]

  # GET /travel_requests/1
  # GET /travel_requests/1.json
  def show; end

  # GET /travel_requests/new
  def new
    # the sync is required since the form currently runs off of the change set model
    # prepopulate creates a default unsaved request event
    travel_request_change_set.prepopulate!.sync
  end

  # GET /travel_requests/1/edit
  def edit
    @travel_request_change_set = travel_request_change_set
  end

  # POST /travel_requests
  # POST /travel_requests.json
  def create
    @travel_request_change_set = travel_request_change_set

    respond_to do |format|
      if travel_request_change_set.validate(processed_params) && travel_request_change_set.save
        @travel_request = travel_request_change_set.model
        format.html { redirect_to @travel_request, notice: "Travel request was successfully created." }
        format.json { render :show, status: :created, location: @travel_request }
      else
        # the sync is required since the form currently runs off of the change set model
        travel_request_change_set.sync
        copy_model_errors_to_change_set
        format.html { render :new }
        format.json { render json: travel_request_change_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /travel_requests/1
  # PATCH/PUT /travel_requests/1.json
  def update
    respond_to do |format|
      if travel_request_change_set.validate(processed_params) && travel_request_change_set.save
        @travel_request = travel_request_change_set.model
        format.html { redirect_to @travel_request, notice: "Travel request was successfully updated." }
        format.json { render :show, status: :ok, location: @travel_request }
      else
        copy_model_errors_to_change_set
        format.html { render :edit }
        format.json { render json: travel_request_change_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_requests/1
  # DELETE /travel_requests/1.json
  def destroy
    @travel_request.destroy
    respond_to do |format|
      format.html { redirect_to travel_requests_url, notice: "Travel request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_travel_request
      @travel_request = TravelRequest.find(params[:id])
    end

    def travel_request_change_set
      @travel_request_change_set ||=
        if params[:id]
          TravelRequestChangeSet.new(TravelRequest.find(params[:id]))
        else
          TravelRequestChangeSet.new(TravelRequest.new)
        end
    end

    def copy_model_errors_to_change_set
      travel_request_change_set.model.errors.each do |key, value|
        @travel_request_change_set.errors.add(key, value)
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def travel_request_params
      clean_params
      params.require(:travel_request).permit(
        :creator_id,
        :start_date,
        :end_date,
        :purpose,
        :participation,
        :travel_category,
        event_requests: [:id, :recurring_event_id, :start_date, :end_date, :location, :url],
        notes: [:creator_id, :content],
        estimates: [:amount, :recurrence, :type]
      )
    end

    # TODO: remove this when the form gets done correctly
    def clean_params
      params[:travel_request][:event_requests] = [params[:travel_request][:event_requests_attributes]["0"]] if params[:travel_request][:event_requests_attributes].present?
    end

    def processed_params
      local = travel_request_params.merge(creator_id: current_staff_profile.id)
      local[:notes] = process_notes(local[:notes])
      local
    end

    def process_notes(notes)
      return notes unless notes
      notes.map do |note_entry|
        note_entry.merge(creator_id: current_staff_profile.id) if note_entry[:content].present?
      end.compact
    end
end
