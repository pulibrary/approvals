# frozen_string_literal: true
# There are three categories of emails that we might send for any action:
#  1. The creator
#  2. The reviewer
#  3. Admin Assistant
# Based on the action we choose the mailer and then send to the peopel if the mailer responds

class MailForAction
  class << self
    def send(request:, action:)
      mailer_class = "#{action.to_s.camelize}RequestMailer".constantize
      send_creator(request: request, mailer_class: mailer_class)
      send_reviewer(request: request, mailer_class: mailer_class)
      send_admin_assistant(request: request, mailer_class: mailer_class)
      send_supervisor(request: request, mailer_class: mailer_class)
    rescue NameError => e
      raise unless e.name == "#{action.to_s.camelize}RequestMailer".to_sym

      Rails.logger.warn("Unexpected action type: #{action}. Try creating a mailer for you action")
    end

    def send_creator(request:, mailer_class:)
      mailer_class.with(request: request).creator_email.deliver if mailer_class.respond_to?(:creator_email)
    end

    def send_reviewer(request:, mailer_class:)
      mailer_class.with(request: request).reviewer_email.deliver if mailer_class.respond_to?(:reviewer_email)
    end

    def send_admin_assistant(request:, mailer_class:)
      mailer_class.with(request: request).admin_assistant_email.deliver if mailer_class.respond_to?(:admin_assistant_email)
    end

    def send_supervisor(request:, mailer_class:)
      mailer_class.with(request: request).supervisor_email.deliver if mailer_class.respond_to?(:supervisor_email)
    end
  end
end
