# frozen_string_literal: true
class ApproveRequestMailer < ApplicationMailer
  def reviewer_email
    return if request.approved?
    mail(to: request.next_supervisor.email, subject: "#{request.title} Ready For Review")
  end

  def supervisor_email
    return unless request.approved? && request.is_a?(TravelRequestDecorator)
    mail(to: request.creator.supervisor.email, subject: "#{request.title} Approved")
  end

  def admin_assistant_email
    return unless request.approved?
    mail(to: request.creator.admin_assistants.map(&:email), subject: "#{request.title} Approved")
  end

  def creator_email
    subject = if request.approved?
                "#{request.title} Approved"
              elsif request.last_supervisor_to_approve
                "#{request.title} Approved by #{request.last_supervisor_to_approve.full_name} Pending Further Review"
              end
    return unless subject
    mail(to: request.creator.email, subject: subject)
  end
end
