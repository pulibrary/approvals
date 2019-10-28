# frozen_string_literal: true
class AbsenceRequestsController < CommonRequestController
  before_action :set_absence_request, only: [:show, :destroy]

  private

    def request_decorator_class
      AbsenceRequestDecorator
    end

    def can_edit?
      @request_change_set.model.pending?
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
          AbsenceRequestChangeSet.new(AbsenceRequest.new)
        end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def absence_request_params
      params.require(:absence_request).permit(:start_date, :end_date, :request_type, :absence_type, :hours_requested, notes: [:content])
    end

    def processed_params
      local = absence_request_params.merge(creator_id: current_staff_profile.id)
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
