# frozen_string_literal: true

class CreateMailer < ApplicationMailer
  def reviewer_email
    if request.creator.supervisor.present?
      mail(to: request.creator.supervisor.email,
           subject: "#{request.title} Ready For Review")
    end
  end

  def creator_email
    # no delegate note was created
    return if request.notes.first.blank? || request.notes.first.creator_id == request.request.creator_id

    mail(to: request.creator.email, subject: "#{request.title} Created by #{request.notes.first.creator.full_name}")
  end
end
