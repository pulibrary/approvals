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

  def reporting_requests
    @requests = RequestListDecorator.new(my_reporting_request_objects, params_hash: request_params.to_h, params_manager_class: ::ReportsParamsManager)
  end

  private

    # all params for this controller
    def request_params
      params.permit(:query, :sort, filters: [:status, :request_type, :department])
    end

    # objects to return to my_request action
    def my_request_objects
      RequestList.list_requests(creator: current_staff_profile, request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"])
    end

    def my_approval_request_objects
      ApprovalRequestList.list_requests(approver: current_staff_profile, request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"])
    end

    def my_reporting_request_objects
      ReportingRequestList.list_requests(creator: current_staff_profile, request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"])
    end
end
