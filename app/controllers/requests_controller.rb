# frozen_string_literal: true
class RequestsController < ApplicationController
  # GET /my_requests
  # GET /my_requests.json
  def my_requests
    @requests = RequestListDecorator.new(my_request_objects, params_hash: request_params.to_h)
  end

  def my_approval_requests
    @requests = RequestListDecorator.new(my_approval_request_objects, params_hash: request_params.to_h, params_manager_class: ::ApprovalsParamsManager)
  end

  def reports
    @requests = ReportListDecorator.new(report_request_objects, params_hash: report_params.to_h, params_manager_class: ::ReportsParamsManager)
  end

  def records
    @requests = RecordListDecorator.new(record_request_objects, params_hash: request_params.to_h, params_manager_class: ::RecordsParamsManager)
  end

  private

    # all params for this controller
    def request_params(filters: [:status, :request_type, :department, :date])
      params.permit(:query, :sort, :page, filters: filters)
    end

    def report_params
      request_params(filters: [:status, :request_type, :department, :date, :employee_type, :supervisor])
    end

    # objects to return to my_request action
    def my_request_objects
      RequestList.list_requests(creator: current_staff_profile,
                                request_filters: request_params[:filters],
                                search_query: request_params[:query],
                                order: request_params["sort"],
                                page: request_params[:page])
    end

    def my_approval_request_objects
      ApprovalRequestList.list_requests(approver: current_staff_profile,
                                        request_filters: request_params[:filters],
                                        search_query: request_params[:query],
                                        order: request_params["sort"],
                                        page: request_params[:page])
    end

    def report_request_objects
      ReportRequestList.list_requests(current_staff_profile: current_staff_profile,
                                      request_filters: report_params[:filters],
                                      search_query: report_params[:query],
                                      order: report_params["sort"])
    end

    def record_request_objects
      RecordRequestList.list_requests(current_staff_profile: current_staff_profile,
                                      request_filters: request_params[:filters],
                                      search_query: request_params[:query],
                                      order: request_params["sort"],
                                      page: request_params[:page])
    end
end
