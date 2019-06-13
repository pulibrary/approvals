# frozen_string_literal: true
json.extract! staff_profile, :id, :user_id, :department_id, :supervisor, :biweekly, :created_at, :updated_at
json.url staff_profile_url(staff_profile, format: :json)
