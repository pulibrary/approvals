# frozen_string_literal: true

#
# These are the common AASM configuration items for both the Absence and Travel request
#
module AasmConfig
  extend ActiveSupport::Concern

  included do
    include AASM

    aasm column: "status", enum: true, no_direct_assignment: true do
      after_all_transitions :log_status_change

      state :pending, initial: true
      state :canceled
      state :approved
      state :denied

      event :approve do
        transitions from: :pending, to: :approved, guard: :only_supervisor
      end

      event :deny do
        transitions from: :pending, to: :denied, guard: :only_supervisor
      end

      event :cancel do
        transitions from: %i[pending approved], to: :canceled, guard: :only_creator
      end
    end
  end

  def log_status_change(agent)
    agent = agent[:agent] if agent.is_a?(Hash)
    StateChange.create(request: self, agent:, action: current_action, delegate: agent.current_delegate)
  end

  def current_action
    action = aasm.to_state
    if (action == :pending) && ((aasm.current_event == :approve!) || (aasm.current_event == :approve))
      action = :approved
    end
    action
  end

  def only_department_head(agent)
    agent = agent[:agent] if agent.is_a?(Hash)
    agent.department_head?
  end

  def only_supervisor(agent)
    agent = agent[:agent] if agent.is_a?(Hash)
    in_supervisor_chain(supervisor: creator.supervisor, agent:)
  end

  def only_creator(agent)
    agent = agent[:agent] if agent.is_a?(Hash)
    creator == agent
  end

  def can_cancel?(agent:)
    only_creator(agent:) && !canceled?
  end

  def can_edit?(agent:)
    only_creator(agent:) && can_modify_attributes?
  end

  private

    def in_supervisor_chain(supervisor:, agent:, previous_supervisor: "no one")
      return false if supervisor.blank?
      # we have a really strange loop in the data where  Bogus, Ian (ibogus) is  Gibbons, Michael P. (mgibbons) supervisor and  Gibbons, Michael P. (mgibbons) is  Bogus, Ian (ibogus) supervisor
      return false if previous_supervisor == supervisor.supervisor

      agent == supervisor || in_supervisor_chain(supervisor: supervisor.supervisor, agent:,
                                                 previous_supervisor: supervisor)
    end
end
