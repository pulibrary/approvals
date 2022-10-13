# frozen_string_literal: true
require "csv"

class ApprovedRequestReport
  attr_reader :start_date
  attr_reader :end_date

  def initialize(start_date:, end_date:)
    @start_date = Date.strptime(start_date, "%m/%d/%Y")
    @end_date = Date.strptime(end_date, "%m/%d/%Y")
  end

  def csv
    headers = ["creator", "status", "start_date", "end_date", "notes", "request_type"]
    CSV.new("", headers: headers)
  end
end
