# frozen_string_literal: true
class CreateMailer < ApplicationMailer
  def reviewer_email
    mail(to: request.creator.supervisor.email, subject: "#{request.title} Ready For Review")
  end
end
