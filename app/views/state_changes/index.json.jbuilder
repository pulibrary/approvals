# frozen_string_literal: true
json.array! @state_changes, partial: "state_changes/state_change", as: :state_change
