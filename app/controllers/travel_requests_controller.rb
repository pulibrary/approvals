# frozen_string_literal: true
class TravelRequestsController < CommonRequestController
  before_action :set_travel_request, only: [:show, :update, :destroy, :review, :approve, :deny]

  # PATCH/PUT
  def decide
    if params[:change_request]
      supervisor_action(action: :change_request)
    else
      super
    end
  end

  private

    def request_decorator_class
      TravelRequestDecorator
    end

    def can_edit?
      @request_change_set.model.pending? || request_change_set.model.changes_requested?
    end

    def list_url
      travel_requests_url
    end

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
        notes: [:content],
        estimates: [:id, :amount, :recurrence, :cost_type, :description]
      )
    end

    def handle_nested_deletes
      remove_estimates
      super
    end

    def remove_estimates
      return if params[:travel_request][:estimates].blank?
      params_estimate_ids = params[:travel_request][:estimates].map { |estimate| estimate[:id] }
      @request.estimates.each do |estimate|
        estimate.destroy if params_estimate_ids.exclude? estimate.id.to_s
      end
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
      local = travel_request_params
      local = local.merge(creator_id: current_staff_profile.id) if request_change_set.model.creator_id.blank?
      local[:notes] = process_notes(local[:notes])
      local
    end

    def process_notes(notes)
      return notes unless notes
      Array(notes).map do |note_entry|
        note_entry.merge(creator_id: current_staff_profile.id) if note_entry[:content].present?
      end.compact
    end
end
