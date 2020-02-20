# frozen_string_literal: true
class RecordsParamsManager < ReportsParamsManager
  def filter_params
    @filter_params ||= existing_params[:filters] || { request_type: "absence" }
  end
end
