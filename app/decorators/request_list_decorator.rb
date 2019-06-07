#
#  RequestListDecorator decorates a request list with the ability to create filter urls, which can be used to filter the results.
#    This decorator supports the My Request page filter drop down menus in addition to supporting the display of the list of results.
#
class RequestListDecorator
  attr_reader :request_list, :params

  delegate :each, :to_a, to: :request_list

  def initialize(request_list, params: nil)
    @request_list = request_list
    @params = params
  end

  # @returns [String] Label for the status dropdown menu
  def current_status_filter_label
    filters = param_filters(params: params)
    if filters["status"].present?
      "Status: #{filters['status'].humanize}"
    else
      "Status"
    end
  end

  # @returns [String] Label for the request type dropdown menu
  def current_request_type_filter_label
    filters = param_filters(params: params)
    if filters["request_type"].present?
      "Request type: #{filters['request_type'].humanize}"
    else
      "Request type"
    end
  end

  # @returns [Hash] Labels and urls for the status dropdown menu
  def status_filter_urls
    filter_urls(params: params, filter_type: "status", filter_value_hash: Request.statuses)
  end

  # @returns [String] url for the absence heading in the request type dropdown menu
  def absence_filter_url
    filter_url(params: params, filter_type: "request_type", filter_value: "absence")
  end

  # @returns [Hash] Labels and urls for the absence entries in the request type dropdown menu
  def absence_filter_urls
    filter_urls(params: params, filter_type: "request_type", filter_value_hash: Request.absence_types)
  end

  # @returns [String] url for the travel heading in the request type dropdown menu
  def travel_filter_url
    filter_url(params: params, filter_type: "request_type", filter_value: "travel")
  end

  # @returns [Hash] Labels and urls for the travel entries in the request type dropdown menu
  def travel_filter_urls
    filter_urls(params: params, filter_type: "request_type", filter_value_hash: Request.travel_categories)
  end

  # @returns [Hash] Labels and urls for removing each of the currently applied filters
  def filter_removal_urls
    filters = param_filters(params: params)
    return {} if filters.empty?
    removal_urls = {}
    filters.each do |key, value|
      removal_urls["#{key.humanize}: #{value.humanize}"] = Rails.application.routes.url_helpers.my_requests_path(
        params: { filters: filters.except(key) }
      )
    end
    removal_urls
  end

  private

    def filter_url(params:, filter_type:, filter_value:)
      Rails.application.routes.url_helpers.my_requests_path(params: { filters: param_filters(params: params).merge(filter_type => filter_value) })
    end

    def filter_urls(params:, filter_type:, filter_value_hash:)
      filters = {}
      filter_value_hash.each do |key, value|
        filters[key.humanize] = filter_url(params: params, filter_type: filter_type, filter_value: value)
      end
      filters
    end

    def param_filters(params:)
      (params.permit(filters: [:status, :request_type])[:filters] || {}).to_h
    end
end
