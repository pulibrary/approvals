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
      Request
        .where(my_request_filters)
        .where_notes_contain(search_query: request_params[:query])
        .order(my_request_order)
    end

    def my_request_filters
      { creator: current_staff_profile }.merge(filters_hash)
    end

    # all filters from params
    def filters_hash
      return {} if request_params[:filters].blank?

      filters = request_params[:filters].to_hash
      map_request_type_filters(filters)
    end

    # These couple methods will likely be reused; consider making it into a class like
    # ParamsToFiltersConverter
    def map_request_type_filters(filters)
      request_type_filter = filters.delete("request_type")
      filters.merge!(request_type_value(request_type_filter)) if request_type_filter.present?
      filters
    end

    # translate a param into a property value
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

    # sort_field can be any field, we use dates to start out with
    # sort_direction can be "asc" or "desc"
    # default is start date, descending
    def my_request_order
      return { "start_date" => "desc" } unless params["sort"]
      sort_field, _, sort_direction = params["sort"].rpartition("_")
      { sort_field => sort_direction }
    end
end
