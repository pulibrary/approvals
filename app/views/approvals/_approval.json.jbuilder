json.extract! approval, :id, :approver_id, :request_id, :approved, :created_at, :updated_at
json.url approval_url(approval, format: :json)
