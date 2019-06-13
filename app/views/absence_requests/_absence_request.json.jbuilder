# frozen_string_literal: true
json.extract! absence_request, :id, :created_at, :updated_at
json.url absence_request_url(absence_request, format: :json)
