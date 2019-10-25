# frozen_string_literal: true
class ApprovalsParamsManager < ParamsManager
  def build_url(params)
    Rails.application.routes.url_helpers.my_approval_requests_path(params: params)
  end
end
