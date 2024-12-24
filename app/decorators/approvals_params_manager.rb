# frozen_string_literal: true

class ApprovalsParamsManager < ParamsManager
  def build_url(params)
    Rails.application.routes.url_helpers.my_approval_requests_path(params:)
  end

  def current_sort
    @params[:sort] || "start_date_asc"
  end
end
