# frozen_string_literal: true

class FixRequestedChangesMailer < ApplicationMailer
  def reviewer_email
    mail(to: request.ordered_state_changes(action: "changes_requested").last.agent.email,
         subject: "#{request.title} Updated and Ready For Review")
  end
end
