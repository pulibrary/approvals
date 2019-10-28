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

  private

    def existing_params
      params.deep_dup
    end

    def build_url(params)
      Rails.application.routes.url_helpers.my_requests_path(params: params)
    end
end
