#
#  RequestListDecorator decorates a request list with the ability to create filter urls, which can be used to filter the results.
#    This decorator supports the My Request page filter drop down menus in addition to supporting the display of the list of results.
#
class RequestListDecorator
  attr_reader :request_list, :params_manager

  delegate :each, :to_a, :map, to: :request_list

  # @param [Array] list of request model objects
  # @param [Hash] params_hash current request paramters; filter and sort options
  def initialize(request_list, params_hash: {})
    @request_list = request_list
    @params_manager = ParamsManager.new(params_hash.deep_symbolize_keys)
  end

  # @returns [String] Label for the status dropdown menu
  def current_status_filter_label
    filters = params_manager.filter_params
    if filters[:status].present?
      "Status: #{filters[:status].humanize}"
    else
      "Status"
    end
  end

  # @returns [String] Label for the request type dropdown menu
  def current_request_type_filter_label
    filters = params_manager.filter_params
    if filters[:request_type].present?
      "Request type: #{filters[:request_type].humanize}"
    else
      "Request type"
    end
  end

  # @returns [Hash] Labels and urls for the status dropdown menu
  def status_filter_urls
    Request.statuses.map do |key, value|
      [key.to_s.humanize, params_manager.url_with_filter(field: :status, new_option: value)]
    end.to_h
  end

  # @returns [String] url for the absence heading in the request type dropdown menu
  def absence_filter_url
    params_manager.url_with_filter(field: :request_type, new_option: "absence")
  end

  # @returns [Hash] Labels and urls for the absence entries in the request type dropdown menu
  def absence_filter_urls
    Request.absence_types.map do |key, value|
      [key.to_s.humanize, params_manager.url_with_filter(field: :request_type, new_option: value)]
    end.to_h
  end

  # @returns [String] url for the travel heading in the request type dropdown menu
  def travel_filter_url
    params_manager.url_with_filter(field: :request_type, new_option: "travel")
  end

  # @returns [Hash] Labels and urls for the travel entries in the request type dropdown menu
  def travel_filter_urls
    Request.travel_categories.map do |key, value|
      [key.to_s.humanize, params_manager.url_with_filter(field: :request_type, new_option: value)]
    end.to_h
  end

  # @returns [Hash] Labels and urls for removing each of the currently applied filters
  def filter_removal_urls
    filters = params_manager.filter_params
    return {} if filters.empty?

    filters.map do |key, value|
      ["#{key.to_s.humanize}: #{value.humanize}", params_manager.url_to_remove_filter(field: key)]
    end.to_h
  end

  # @returns [Hash] Labels and urls for sorting the results, while maintaining
  # currently applied filters
  def sort_urls
    {
      "Start date - ascending" => params_manager.url_with_sort(new_option: "start_date_asc"),
      "Start date - descending" => params_manager.url_with_sort(new_option: "start_date_desc"),
      "Date created - ascending" => params_manager.url_with_sort(new_option: "date_created_asc"),
      "Date created - descending" => params_manager.url_with_sort(new_option: "date_created_desc"),
      "Date modified - ascending" => params_manager.url_with_sort(new_option: "date_modified_asc"),
      "Date modified - descending" => params_manager.url_with_sort(new_option: "date_modified_desc")
    }
  end
end

#
# This is a helper class to build the urls maintaining existing sort and filter options
class ParamsManager
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def url_with_filter(field:, new_option:)
    new_params = existing_params
    new_params[:filters] = filter_params.merge(field => new_option)
    build_url(new_params)
  end

  def url_with_sort(new_option:)
    new_params = existing_params
    new_params[:sort] = new_option
    build_url(new_params)
  end

  def url_to_remove_filter(field:)
    new_params = existing_params
    new_params[:filters] = filter_params.except(field)
    build_url(new_params)
  end

  def filter_params
    @filter_params ||= existing_params[:filters] || {}
  end

  private

    def existing_params
      params.deep_dup
    end

    def build_url(params)
      Rails.application.routes.url_helpers.my_requests_path(params: params)
    end
end
