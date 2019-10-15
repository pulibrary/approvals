# frozen_string_literal: true
class RequestsController < ApplicationController
  # GET /my_requests
  # GET /my_requests.json
  def my_requests
    @requests = RequestListDecorator.new(my_request_objects, params_hash: request_params.to_h)
  end

  private

    # all params for this controller
    def request_params
      params.permit(:query, :sort, filters: [:status, :request_type])
    end

    # objects to return to my_request action
    def my_request_objects
      RequestList.list_requests(creator: current_staff_profile, request_filters: request_params[:filters], search_query: request_params[:query], order: params["sort"])
    end
end
