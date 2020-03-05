# frozen_string_literal: true
class CancelMailer < ApplicationMailer
  def supervisor_email
    mail(to: request.creator.supervisor.email, subject: "#{request.title} Canceled")
  end

  def admin_assistant_email
    last_state = request.previous_state
    return unless last_state && (last_state.approved? || last_state.recorded?)
    return if request.creator.admin_assistants.empty?
    mail(to: request.creator.admin_assistants.map(&:email), subject: "#{request.title} Canceled")
  end
end
