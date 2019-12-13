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

  def records
    @requests = RequestListDecorator.new(recording_request_objects, params_hash: request_params.to_h, params_manager_class: ::RecordsParamsManager)
  end

  def reports
    objects = report_request_objects
    puts "Objects = #{objects}"
    @requests = ReportListDecorator.new(objects, params_hash: request_params.to_h, params_manager_class: ::ReportsParamsManager)
  end

  private

    # all params for this controller
    def request_params
      params.permit(:query, :sort, filters: [:status, :request_type, :department, :date])
    end

    # objects to return to my_request action
    def my_request_objects
      RequestList.list_requests(creator: current_staff_profile, request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"], page: params[:page])
    end

    def my_approval_request_objects
      ApprovalRequestList.list_requests(approver: current_staff_profile, request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"], page: params[:page])
    end

    def report_request_objects
      ReportRequestList.list_requests(request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"], page: params[:page])
    end

    def recording_request_objects
      RecordingRequestList.list_requests(request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"], page: params[:page])
    end
end
