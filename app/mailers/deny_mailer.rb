# frozen_string_literal: true

class DenyMailer < ApplicationMailer
  def creator_email
    mail(to: request.creator.email, subject: "#{request.title} Denied")
  end

  def supervisor_email
    unless request.is_a?(TravelRequestDecorator) && @request.latest_state_change.agent != request.creator.supervisor
      return
    end

    mail(to: request.creator.supervisor.email, subject: "#{request.title} Denied")
  end
end
