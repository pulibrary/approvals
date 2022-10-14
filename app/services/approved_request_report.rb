# frozen_string_literal: true
require "csv"

class ApprovedRequestReport
  attr_reader :start_date
  attr_reader :end_date
  attr_reader :file_path

  def initialize(start_date:, end_date:, file_path: "./tmp/approved_request_report.csv")
    @start_date = Date.strptime(start_date, "%m/%d/%Y")
    @end_date = Date.strptime(end_date, "%m/%d/%Y")
    @file_path = file_path
  end

  def csv
    headers = ["start_date", "end_date", "event_name", "trip_id", "surname", "given_name", "department", "estimated_cost"]

    CSV.open(file_path, "wb") do |csv|
      csv << headers
      TravelRequest.find_each do |request|
        next unless request.approved? && in_report_period?(request)
        csv << [request.start_date, request.end_date, request.event_title, request.id, request.creator.surname, request.creator.given_name,
                request.creator.department.name, format("%.2f", request.estimated_total)]
      end
    end
  end

  def in_report_period?(request)
    request.start_date.between?(@start_date, @end_date) || request.end_date.between?(@start_date, @end_date)
  end
end
