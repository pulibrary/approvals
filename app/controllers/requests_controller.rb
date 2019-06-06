class RequestsController < ApplicationController
  # GET /my_requests
  # GET /my_requests.json
  def my_requests
    @requests = Request.where(creator: current_staff_profile)
  end
end
