# frozen_string_literal: true

class ReportsParamsManager < ParamsManager
  def build_url(params)
    Rails.application.routes.url_helpers.reports_path(params:)
  end

  def current_sort
    @params[:sort] || "start_date_asc"
  end

  def filter_params
    @filter_params ||= existing_params[:filters] || {}
  end
end
