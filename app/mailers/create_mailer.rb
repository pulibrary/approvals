# frozen_string_literal: true
class CreateMailer < ApplicationMailer
  def reviewer_email
    mail(to: request.creator.supervisor.email, subject: "#{request.title} Ready For Review") if request.creator.supervisor.present?
  end

  def creator_email
    # no delegate note was created
    return if request.notes.last.blank? || request.notes.first.creator_id == request.request.creator_id

    mail(to: request.creator.email, subject: "#{request.title} Created by #{request.notes.first.creator.full_name}")
  end
end
