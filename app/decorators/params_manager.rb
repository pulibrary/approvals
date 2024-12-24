# frozen_string_literal: true

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

  def current_sort
    @params[:sort] || "updated_at_desc"
  end

  def date_form_hidden_field
    new_params = existing_params
    filters = filter_params.except(:date)
    new_params.delete(:filters)
    filters.each do |key, value|
      new_params["filters[#{key}]"] = value
    end
    new_params
  end

  def date_defaults
    dates = RequestList.parse_date_range_filter(filter: filter_params[:date])
    start_date = dates[:start]
    return "" if start_date.blank?

    end_date = dates[:end]
    "{ start: new Date(#{start_date.year}, #{start_date.month - 1}, #{start_date.day}), end: new Date(#{end_date.year}, #{end_date.month - 1}, #{end_date.day})}"
  rescue ArgumentError
    ""
  end

  private

    def existing_params
      params.deep_dup
    end

    def build_url(params)
      Rails.application.routes.url_helpers.my_requests_path(params:)
    end
end
