# frozen_string_literal: true
# This is a helper class to build the urls maintaining existing sort and filter options
class RecordsParamsManager < ParamsManager
  def build_url(params)
    Rails.application.routes.url_helpers.records_path(params: params)
  end

  def current_sort
    @params[:sort] || "start_date_asc"
  end

  def filter_params
    @filter_params ||= existing_params[:filters] || {}
  end
end
