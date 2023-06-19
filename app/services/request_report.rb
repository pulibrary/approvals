# frozen_string_literal: true
require "csv"

class RequestReport
  attr_reader :start_date
  attr_reader :end_date
  attr_reader :file_path

  def initialize(start_date:, end_date:, file_path: "./tmp/approved_request_report.csv", approved_only: false)
    @start_date = Date.strptime(start_date, "%m/%d/%Y")
    @end_date = Date.strptime(end_date, "%m/%d/%Y")
    @file_path = file_path
    @approved_only = approved_only
  end

  def csv
    headers = ["start_date", "end_date", "event_name", "trip_id", "surname", "given_name", "department", "estimated_cost", "status", "event_format"]

    CSV.open(file_path, "wb") do |csv|
      csv << headers
      TravelRequest.includes(:estimates, creator: [:department]).find_each do |request|
        next unless valid_state?(request) && in_report_period?(request)
        csv << [request.start_date, request.end_date, request.event_title, request.id, request.creator.surname, request.creator.given_name,
                request.creator.department.name, format("%.2f", request.estimated_total), request.status, request.event_format]
      end
    end
  end

  def valid_state?(request)
    return true unless @approved_only

    request.approved?
  end

  def in_report_period?(request)
    return false unless request.start_date && request.end_date

    request.start_date.between?(@start_date, @end_date) || request.end_date.between?(@start_date, @end_date)
  end
end
