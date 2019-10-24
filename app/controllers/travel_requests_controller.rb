# frozen_string_literal: true
class TravelRequestsController < ApplicationController
  before_action :set_travel_request, only: [:show, :update, :destroy]

  # GET /travel_requests/1
  # GET /travel_requests/1.json
  def show
    @request = TravelRequestDecorator.new(@request)
  end

  # GET /travel_requests/new
  def new
    # the sync is required since the form currently runs off of the change set model
    # prepopulate creates a default unsaved request event
    request_change_set.prepopulate!.sync
  end

  # GET /travel_requests/1/edit
  def edit
    @request_change_set = request_change_set
  end

  # POST /travel_requests
  # POST /travel_requests.json
  def create
    @request_change_set = request_change_set

    respond_to do |format|
      if request_change_set.validate(processed_params) && request_change_set.save
        @request = request_change_set.model
        format.html { redirect_to @request, notice: "Travel request was successfully created." }
        format.json { render :show, status: :created, location: @request }
      else
        # the sync is required since the form currently runs off of the change set model
        request_change_set.sync
        copy_model_errors_to_change_set
        format.html { render :new }
        format.json { render json: request_change_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /travel_requests/1
  # PATCH/PUT /travel_requests/1.json
  def update
    respond_to do |format|
      if request_change_set.validate(processed_params) && remove_estimates && request_change_set.save
        @request = request_change_set.model
        format.html { redirect_to @request, notice: "Travel request was successfully updated." }
        format.json { render :show, status: :ok, location: @request }
      else
        copy_model_errors_to_change_set
        format.html { render :edit }
        format.json { render json: request_change_set.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /travel_requests/1
  # DELETE /travel_requests/1.json
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to travel_requests_url, notice: "Travel request was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_travel_request
      @request = TravelRequest.find(params[:id])
    end

    def request_change_set
      @request_change_set ||=
        if params[:id]
          TravelRequestChangeSet.new(TravelRequest.find(params[:id]))
        else
          TravelRequestChangeSet.new(TravelRequest.new)
        end
    end

    def copy_model_errors_to_change_set
      request_change_set.model.errors.each do |key, value|
        @request_change_set.errors.add(key, value)
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
        estimates: [:id, :amount, :recurrence, :cost_type, :description]
      )
    end

    def remove_estimates
      return true if params[:travel_request][:estimates].blank?
      params_estimate_ids = params[:travel_request][:estimates].map { |estimate| estimate[:id] }
      @request.estimates.each do |estimate|
        estimate.destroy if params_estimate_ids.exclude? estimate.id.to_s
      end
      true
    end

    # TODO: remove this when the form gets done correctly
    def clean_params
      params[:travel_request][:event_requests] = [params[:travel_request][:event_requests_attributes]["0"]] if params[:travel_request][:event_requests_attributes].present?

      parse_date(params[:travel_request][:event_requests][0], :event_dates) if params[:travel_request][:event_requests].present?
      parse_date(params[:travel_request], :travel_dates)
    end

    def parse_date(hash, field)
      return if hash.blank? || hash[field].blank?
      dates = hash[field].split(" - ")
      hash[:start_date] = Date.strptime(dates[0], "%m/%d/%Y")
      hash[:end_date] = Date.strptime(dates[1], "%m/%d/%Y")
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
