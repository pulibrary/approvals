# frozen_string_literal: true
class TravelRequestsController < CommonRequestController
  before_action :set_travel_request, only: [:show, :update, :destroy, :review, :approve, :deny]

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  # PATCH/PUT
  def decide
    if params[:change_request]
      pending_errors.push({ attribute: :notes, type: "are required to specify requested changes." }) if processed_params[:notes].blank?
      run_action(action: :change_request, change_method: :supervisor_can_change?)
    elsif params[:change_event]
      update_event
    else
      pending_errors.push({ attribute: :travel_category, type: "is required to approve." }) if params[:approve] && processed_params[:travel_category].blank? && current_staff_profile.department_head?
      super
    end
  end
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/PerceivedComplexity

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
      @travel_request_params ||= clean_and_require_params
    end

    def clean_and_require_params
      clean_params
      params.require(:travel_request).permit(
        :creator_id,
        :start_date,
        :end_date,
        :purpose,
        :participation,
        :travel_category,
        :virtual_event,
        event_requests: [:id, :recurring_event_id, :start_date, :end_date, :location, :url],
        notes: [:content],
        new_event: [:id],
        estimates: [:id, :amount, :recurrence, :cost_type, :description]
      )
    end

    def handle_nested_deletes
      remove_estimates
      super
    end

    def remove_estimates
      return if params[:travel_request][:estimates].blank?
      params_estimate_ids = params[:travel_request][:estimates].pluck(:id)
      @request.estimates.each do |estimate|
        estimate.destroy if params_estimate_ids.exclude? estimate.id.to_s
      end
    end

    # TODO: remove this when the form gets done correctly
    def clean_params
      return if params[:travel_request].blank?
      params[:travel_request][:event_requests] = [params[:travel_request][:event_requests_attributes]["0"]] if params[:travel_request][:event_requests_attributes].present?

      parse_date(params[:travel_request][:event_requests][0], :event_dates) if params[:travel_request][:event_requests].present?
      parse_date(params[:travel_request], :travel_dates)
    end

    def parse_date(hash, field)
      return if hash.blank? || hash[field].blank?
      dates = RequestList.parse_date_range_filter(filter: hash[field])
      hash[:start_date] = dates[:start]
      hash[:end_date] = dates[:end]
    rescue ArgumentError
      pending_errors.push({ attribute: field, type: "must be in a valid format (mm/dd/yyyy - mm/dd/yyyy)" })
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

    def update_event
      set_travel_request

      if processed_params[:new_event][:id].blank?
        redirect_to({ action: "review", id: @request.id }, flash: { alert: t("travel_requests.event_name_required") })
      else
        new_recurring_event = RecurringEvent.find(processed_params[:new_event][:id])

        @request.update_recurring_events!(target_recurring_event: new_recurring_event)

        redirect_to({ action: "review", id: @request.id }, flash: { success: "Travel request event name was successfully updated." })
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to({ action: "review", id: @request.id }, flash: { alert: t("travel_requests.event_name_does_not_exist") }) unless new_recurring_event
    end
end
