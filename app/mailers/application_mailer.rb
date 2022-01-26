# frozen_string_literal: true

# Main class for sending mail
class ApplicationMailer < ActionMailer::Base
  default from: "approvals@princeton.edu"
  layout "mailer"

  private

  def request
    @request ||= if request_param.is_a?(TravelRequest)
                   TravelRequestDecorator.new(request_param)
                 else
                   AbsenceRequestDecorator.new(request_param)
                 end
  end

  def request_param
    @request_param ||= params[:request]
  end
end
