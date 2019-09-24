# frozen_string_literal: true
def fire_event_safely(request:, action:, agent:)
  action = action.to_sym
  if action == :record
    request.approve(agent: agent)
  elsif action == :pending_cancel
    request.approve(agent: agent)
    request.record(agent: agent)
  elsif action == :cancel
    agent = request.creator
  end

  request.aasm.fire(action, agent: agent)
end
