# frozen_string_literal: true
class AbsenceRequestsController < CommonRequestController
  before_action :set_absence_request, only: [:show, :destroy, :review, :approve, :deny, :decide]

  # PATCH/PUT
  def decide
    if params[:record]
      run_action(action: :record, change_method: :can_record?)
    else
      super
    end
  end

  private

    def request_decorator_class
      AbsenceRequestDecorator
    end

    def list_url
      absence_requests_url
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_absence_request
      @request = AbsenceRequest.find(params[:id])
    end

    def request_change_set
      @request_change_set ||=
        if params[:id]
          AbsenceRequestChangeSet.new(AbsenceRequest.find(params[:id]))
        else
          AbsenceRequestChangeSet.new(AbsenceRequest.new, current_staff_profile: current_staff_profile)
        end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def absence_request_params
      params.require(:absence_request).permit(:start_date, :end_date, :request_type, :absence_type, :hours_requested, notes: [:content])
    end

    def processed_params
      local = absence_request_params
      local = local.merge(creator_id: current_staff_profile.id) if request_change_set.model.creator_id.blank?
      local[:notes] = process_notes(local[:notes])
      local
    end

    def process_request_params?
      params.include?(:absence_request)
    end

    def can_record?(action:)
      allowed_to_change = request_change_set.model.can_record?(agent: current_staff_profile)
      respond_to_change_error(action: action, allowed_to_change: allowed_to_change)
    end
end
