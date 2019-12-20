# frozen_string_literal: true
# There are three categories of emails that we might send for any action:
#  1. The creator
#  2. The reviewer
#  3. Admin Assistant
# Based on the action we choose the mailer and then send to the peopel if the mailer responds

class MailForAction
  class << self
    def send(request:, action:)
      mailer_class = "#{action.to_s.titleize}RequestMailer".constantize
      mailer_class.with(request: request).creator_email.deliver if mailer_class.respond_to?(:creator_email)
      mailer_class.with(request: request).reviewer_email.deliver if mailer_class.respond_to?(:reviewer_email)
      mailer_class.with(request: request).admin_assitant_email.deliver if mailer_class.respond_to?(:admin_assitant_email)
    rescue NameError
      Rails.logger.warn("Unexpected action type: #{action}. Try creating a mailer for you action")
    end
  end
end
