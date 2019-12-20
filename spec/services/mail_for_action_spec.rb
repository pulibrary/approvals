# frozen_string_literal: true
require "rails_helper"

RSpec.describe MailForAction, type: :model do
  let(:request) { FactoryBot.create :travel_request }
  describe "send" do
    it "sends email for the create action" do
      # TODO: for the moment we are just responding to the creator, but in the future we will want to send out to the approver
      #      and possibly the AAs
      expect { MailForAction.send(request: request, action: "create") }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Ready For Review"
      expect(mail.to).to eq [request.creator.supervisor.email]
    end

    it "logs warning for an unknown action" do
      allow(Rails.logger).to receive(:warn)
      expect { MailForAction.send(request: request, action: "bad_action") }.to change { ActionMailer::Base.deliveries.count }.by(0)
      expect(Rails.logger).to have_received(:warn).with("Unexpected action type: bad_action. Try creating a mailer for you action")
    end
  end
end
