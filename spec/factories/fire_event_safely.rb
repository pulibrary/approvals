# frozen_string_literal: true
def fire_event_safely(request:, action:, agent:)
  action = action.to_sym
  if action == :record
    request.approve(agent: agent)
  elsif action == :cancel
    agent = request.creator
  elsif action == :fix_requested_changes
    request.change_request(agent: agent)
    agent = request.creator
  end

  request.aasm.fire(action, agent: agent)
end
