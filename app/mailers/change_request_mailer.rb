# frozen_string_literal: true
class ChangeRequestMailer < ApplicationMailer
  def creator_email
    mail(to: request.creator.email, subject: "#{request.title} Request Changes")
  end

  def supervisor_email
    return unless request.latest_state_change.agent != request.creator.supervisor

    mail(to: request.creator.supervisor.email, subject: "#{request.title} Request Changes")
  end
end
