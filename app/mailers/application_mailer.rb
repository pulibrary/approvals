# frozen_string_literal: true

# Main class for sending mail
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout "mailer"
end
