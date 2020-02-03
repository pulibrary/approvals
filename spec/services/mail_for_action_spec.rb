# frozen_string_literal: true
require "rails_helper"

RSpec.describe MailForAction, type: :model do
  let(:supervisor) { FactoryBot.create :staff_profile, :with_department, given_name: "Jane", surname: "Smith" }
  let(:creator) { FactoryBot.create :staff_profile, supervisor: supervisor, department: supervisor.department }
  let(:request) { FactoryBot.create :travel_request, creator: creator }
  describe "send" do
    it "sends email for the create action" do
      expect { MailForAction.send(request: request, action: "create") }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Ready For Review"
      expect(mail.to).to eq [request.creator.supervisor.email]
    end

    it "sends email to the creator if a delegate created the event" do
      Note.create request: request, creator: supervisor, content: "I created this"
      expect { MailForAction.send(request: request.reload, action: "create") }.to change { ActionMailer::Base.deliveries.count }.by(2)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Ready For Review"
      expect(mail.to).to eq [request.creator.supervisor.email]
      creator_mail = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
      expect(creator_mail.to).to eq [request.creator.email]
      expect(creator_mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Created by Jane Smith"
    end

    it "sends email for the approve action" do
      request.approve(agent: supervisor)
      expect { MailForAction.send(request: request, action: "approve") }.to change { ActionMailer::Base.deliveries.count }.by(2)
      review_mail = ActionMailer::Base.deliveries.last
      expect(review_mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Ready For Review"
      expect(review_mail.to).to eq [supervisor.supervisor.email]
      approved_mail = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
      expect(approved_mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Approved by Jane Smith Pending Further Review"
      expect(approved_mail.to).to eq [request.creator.email]
    end

    it "sends email for the final approval action" do
      request.approve(agent: supervisor)
      request.approve(agent: supervisor.supervisor)
      request.approve(agent: supervisor.supervisor.supervisor)
      expect { MailForAction.send(request: request, action: "approve") }.to change { ActionMailer::Base.deliveries.count }.by(3)
      supervisor_mail = ActionMailer::Base.deliveries.last
      expect(supervisor_mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Approved"
      expect(supervisor_mail.to).to eq [supervisor.email]
      admin_mail = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 2]
      expect(admin_mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Approved"
      expect(admin_mail.to).to eq supervisor.department.admin_assistants.map(&:email)
      approved_mail = ActionMailer::Base.deliveries[ActionMailer::Base.deliveries.count - 3]
      expect(approved_mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Approved"
      expect(approved_mail.to).to eq [creator.email]
    end

    it "sends email for the change request action" do
      request.change_request(agent: supervisor)
      expect { MailForAction.send(request: request, action: "change_request") }.to change { ActionMailer::Base.deliveries.count }.by(1)
      review_mail = ActionMailer::Base.deliveries.last
      expect(review_mail.subject).to eq "#{TravelRequestDecorator.new(request).title} Request Changes"
      expect(review_mail.to).to eq [request.creator.email]
    end

    it "logs warning for an unknown action" do
      allow(Rails.logger).to receive(:warn)
      expect { MailForAction.send(request: request, action: "bad") }.to change { ActionMailer::Base.deliveries.count }.by(0)
      expect(Rails.logger).to have_received(:warn).with("Unexpected action type: bad. Try creating a mailer for you action")
    end

    it "raises and error for a bad request unknown action" do
      expect { MailForAction.send(request: nil, action: "approve") }.to raise_error NameError
    end
  end
end
