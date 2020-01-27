# frozen_string_literal: true
class TravelRequestsController < CommonRequestController
  before_action :set_travel_request, only: [:show, :update, :destroy, :review, :approve, :deny]

  # PATCH/PUT
  def decide
    if params[:change_request]
      request_change_set.errors.add(:notes, "Notes are required to specify requested changes.") if processed_params[:notes].blank?
      run_action(action: :change_request, change_method: :supervisor_can_change?)
    else
      super
    end
  end

  # PATCH/PUT
  def update
    return unless super && @request.changes_requested?
    @request.fix_requested_changes!(agent: current_staff_profile)
    MailForAction.send(request: @request, action: "fix_requested_changes")
  end

  # GET
  def review
    return if !super || current_profile_has_not_already_reviewed

    respond_with_show_error(message: "You have already reviewed the request.", status: :invalid_edit)
  end

  private

    def current_profile_has_not_already_reviewed
      @request.latest_state_change.blank? || @request.latest_state_change.agent != current_staff_profile
    end

    def request_decorator_class
      TravelRequestDecorator
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
          TravelRequestChangeSet.new(TravelRequest.new, current_staff_profile: current_staff_profile)
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

    def process_request_params?
      params.include?(:travel_request)
    end
end
