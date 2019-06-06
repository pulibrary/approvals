class RequestsController < ApplicationController
  # GET /my_requests
  # GET /my_requests.json
  def my_requests
    @requests = Request.where(my_request_filters)
  end

  private

    def my_request_filters
      { creator: current_staff_profile }.merge(filters_hash)
    end

    def filters_hash
      return {} if request_params[:filters].blank?

      filters = request_params[:filters].to_hash
      map_request_type_filters(filters)
    end

    def request_params
      params.permit(filters: [:status, :request_type])
    end

    # These couple methods will likely be reused; consider making it into a class like
    # ParamsToFiltersConverter
    def map_request_type_filters(filters)
      request_type_filter = filters.delete("request_type")
      filters.merge!(request_type_value(request_type_filter)) if request_type_filter.present?
      filters
    end

    def request_type_value(param_value)
      if param_value == "absence"
        { request_type: "AbsenceRequest" }
      elsif param_value == "travel"
        { request_type: "TravelRequest" }
      elsif Request.travel_categories.values.include?(param_value)
        { travel_category: param_value }
      else
        { absence_type: param_value }
      end
    end
end
