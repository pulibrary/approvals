# frozen_string_literal: true
class CreateRequestMailer < ApplicationMailer
  default from: "approvals@princeton.edu"

  def reviewer_email
    request = params[:request]
    @request = if request.is_a?(TravelRequest)
                 TravelRequestDecorator.new(request)
               else
                 AbsenceRequestDecorator.new(request)
               end

    mail(to: @request.creator.supervisor.email, subject: "#{@request.title} Ready For Review")
  end
end
