json.extract! state_change, :id, :approver_id, :request_id, :approved, :created_at, :updated_at
json.url state_change_url(state_change, format: :json)