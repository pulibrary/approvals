# frozen_string_literal: true
#
#  RequestListDecorator decorates a request list with the ability to create filter urls, which can be used to filter the results.
#    This decorator supports the My Request page filter drop down menus in addition to supporting the display of the list of results.
#
class RequestListDecorator
  attr_reader :request_list, :params_manager, :original_list

  delegate :count, :each, :first, :last, :map, :to_a, to: :request_list
  delegate :total_pages, :current_page, :limit_value, to: :original_list

  # @param [Array] list of request model objects
  # @param [Hash] params_hash current request paramters; filter and sort options
  def initialize(request_list, params_hash: {}, params_manager_class: ParamsManager)
    @original_list = request_list
    @request_list = request_list.map do |request|
      if request.is_a?(TravelRequest)
        TravelRequestDecorator.new(request)
      else
        AbsenceRequestDecorator.new(request)
      end
    end
    @params_manager = params_manager_class.new(params_hash.deep_symbolize_keys)
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

  # @returns [String] Label for the sort dropdown menu
  def current_sort_label
    sort = params_manager.current_sort
    "Sort: #{sort_options_table[sort]}"
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
      [filter_label(key, value), params_manager.url_to_remove_filter(field: key)]
    end.to_h
  end

  def filter_label(key, value)
    "#{key.to_s.humanize}: #{value.humanize}"
  end

  # @returns [Hash] Labels and urls for sorting the results, while maintaining
  # currently applied filters
  def sort_urls
    sort_options_table.map { |value, label| [label, params_manager.url_with_sort(new_option: value)] }.to_h
  end

  def request_type_filters
    filters = {}
    filters["Absence"] = { url: absence_filter_url, children: absence_filter_urls } if Rails.configuration.show_absence_button
    filters["Travel"] = { url: travel_filter_url, children: travel_filter_urls }
    filters
  end

  private

    def sort_options_table
      {
        "start_date_asc" => "Start date - ascending",
        "start_date_desc" => "Start date - descending",
        "created_at_asc" => "Date created - ascending",
        "created_at_desc" => "Date created - descending",
        "updated_at_asc" => "Date modified - ascending",
        "updated_at_desc" => "Date modified - descending"
      }
    end
end
