class RequestsController < ApplicationController
  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.all
  end
end
