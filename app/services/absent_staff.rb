# frozen_string_literal: true
class AbsentStaff
  class << self
    def list(start_date:, end_date:)
      absence_requests =
        AbsenceRequest.where(start_date: start_date..end_date).or(
          AbsenceRequest.where(end_date: start_date..end_date)
        ).or(
          AbsenceRequest.where("start_date <= ? and end_date >= ?", start_date, end_date)
        )

      absence_requests.map(&:creator)
    end
  end
end
