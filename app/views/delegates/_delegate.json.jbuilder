# frozen_string_literal: true

json.extract! delegate, :id, :staff_profile_id, :created_at, :updated_at
json.url delegate_url(delegate, format: :json)
