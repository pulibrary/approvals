# frozen_string_literal: true
class AbsentStaff
  class << self
    def list(start_date:, end_date:, supervisor:)
      request_creator_join = AbsenceRequest.joins(:creator)
      absence_requests =
        request_creator_join.where(start_date: start_date..end_date, 'staff_profiles.supervisor_id': supervisor.id).or(
          request_creator_join.where(end_date: start_date..end_date, 'staff_profiles.supervisor_id': supervisor.id)
        ).or(
          request_creator_join.where("start_date <= ? and end_date >= ? and staff_profiles.supervisor_id = ?",
                                     start_date, end_date, supervisor.id)
        )

      absence_requests.map(&:creator)
    end
  end
end
