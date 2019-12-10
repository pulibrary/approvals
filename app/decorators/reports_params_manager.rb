# frozen_string_literal: true
class ReportsParamsManager < ParamsManager
  def build_url(params)
    Rails.application.routes.url_helpers.reporting_requests_path(params: params)
  end

  def current_sort
    @params[:sort] || "start_date_asc"
  end
end
