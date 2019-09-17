# frozen_string_literal: true
json.extract! state_change, :id, :agent_id, :request_id, :approved, :created_at, :updated_at
json.url state_change_url(state_change, format: :json)
