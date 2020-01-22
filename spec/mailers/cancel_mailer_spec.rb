# frozen_string_literal: true
require "rails_helper"

RSpec.describe CancelMailer, type: :mailer do
  let(:supervisor) do
    aa = FactoryBot.create(:staff_profile, given_name: "Sally", surname: "Smith")
    head = FactoryBot.create(:staff_profile, given_name: "Department", surname: "Head")
    department = FactoryBot.create(:department, head: head, admin_assistants: [aa])
    FactoryBot.create :staff_profile, department: department, given_name: "Jane", surname: "Smith", supervisor: head
  end

  let(:user) { FactoryBot.create :user, uid: "jd4" }
  let(:creator) { FactoryBot.create :staff_profile, user: user, given_name: "Joe", surname: "Doe", supervisor: supervisor, department: supervisor.department }
  let(:travel_request) { FactoryBot.create :travel_request, creator: creator, start_date: Date.parse("2019/12/30"), end_date: Date.parse("2019/12/31") }
  let(:absence_request) { FactoryBot.create :absence_request, creator: creator, start_date: Date.parse("2019/12/30"), end_date: Date.parse("2019/12/31") }
  let(:today_formatted) { Time.zone.now.strftime(Rails.configuration.short_date_format) }

  context "unapproved absence" do
    before do
      absence_request.cancel(agent: creator)
    end

    it "does not send AA emails" do
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "does not send creator emails" do
      expect { described_class.with(request: absence_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "Sends supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p></p>\n<p>To view the canceled request go to " \
                                             "<a href=\"http://localhost:3000/absence_requests/#{absence_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.\n\n" \
                                             "To view the canceled request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end
  end

  context "approved absence" do
    before do
      absence_request.approve(agent: supervisor)
      absence_request.cancel(agent: creator)
    end

    it "sends AA emails" do
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Approved by Jane Smith on #{today_formatted}.</p>\n" \
                                             "<p>To view the request go to <a href=\"http://localhost:3000/absence_requests/#{absence_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.\n" \
                                             "It was Approved by Jane Smith on #{today_formatted}.\nTo view the request go to http://localhost:3000/absence_requests/#{absence_request.id}\n\n")
    end

    it "does not send creator emails" do
      expect { described_class.with(request: absence_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "sends supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Approved by Jane Smith on #{today_formatted}.</p>\n" \
                                             "<p>To view the canceled request go to <a href=\"http://localhost:3000/absence_requests/#{absence_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.\n" \
                                             "It was Approved by Jane Smith on #{today_formatted}.\nTo view the canceled request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end
  end

  context "recorded absence" do
    before do
      absence_request.approve(agent: supervisor)
      absence_request.record(agent: creator.admin_assistants.first)
      absence_request.pending_cancel(agent: creator)
    end

    it "sends AA emails" do
      pending "We do not really have the record routes yet"
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "Cancelation has been requested by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Recorded by Sally Smith on #{today_formatted}.</p>\n" \
                                             "<p>To complete the cancelation after you have recorded the change go to " \
                                             "<a href=\"http://localhost:3000/absence_requests/#{absence_request.id}/record\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  Cancelation has been requested by Joe Doe on #{today_formatted}.\n" \
                                             "It was Recorded by Sally Smith on #{today_formatted}.  " \
                                             "To complete the cancelation after you have recorded the change go to http://localhost:3000/absence_requests/#{absence_request.id}/record\n")
    end

    it "sends creator emails" do
      expect { described_class.with(request: absence_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "Vacation Cancelation Requested"
      expect(mail.to).to eq [creator.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted on #{today_formatted}.  " \
                                             "To complete the cancelation it must be recorded.</h1>\n" \
                                             "<p>It was Recorded by Sally Smith on #{today_formatted}.</p>\n" \
                                             "<p>To view your request go to <a href=\"http://localhost:3000/absence_requests/#{absence_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted on #{today_formatted}.  To complete the cancelation it must be recorded.\n" \
                                            "It was Recorded by Sally Smith on #{today_formatted}.\n" \
                                            "To view your request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end

    it "sends a supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "Cancelation has been requested by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Recorded by Sally Smith on #{today_formatted}.</p>\n" \
                                             "<p>To view the canceled request go to <a href=\"http://localhost:3000/absence_requests/#{absence_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  Cancelation has been requested by Joe Doe on #{today_formatted}.\n" \
                                             "It was Recorded by Sally Smith on #{today_formatted}.\nTo view the canceled request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end
  end

  context "partially approve travel request" do
    before do
      travel_request.approve(agent: supervisor)
      travel_request.cancel(agent: creator)
    end

    it "sends AA emails" do
      expect { described_class.with(request: travel_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Approved by Jane Smith on #{today_formatted}.</p>\n" \
                                             "<p>To view the request go to <a href=\"http://localhost:3000/travel_requests/#{travel_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.\n" \
                                             "It was Approved by Jane Smith on #{today_formatted}.\nTo view the request go to http://localhost:3000/travel_requests/#{travel_request.id}\n\n")
    end

    it "does not send a creator email" do
      expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "sends a supervisor email" do
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Approved by Jane Smith on #{today_formatted}.</p>\n" \
                                             "<p>To view the canceled request go to <a href=\"http://localhost:3000/travel_requests/#{travel_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.\n" \
                                             "It was Approved by Jane Smith on #{today_formatted}.\nTo view the canceled request go to http://localhost:3000/travel_requests/#{travel_request.id}\n")
    end
  end

  context "approved travel request" do
    before do
      travel_request.approve(agent: supervisor)
      travel_request.approve(agent: supervisor.department.head)
      travel_request.cancel(agent: creator)
    end

    it "sends AA emails" do
      expect { described_class.with(request: travel_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Approved by Department Head on #{today_formatted}.</p>\n" \
                                             "<p>To view the request go to <a href=\"http://localhost:3000/travel_requests/#{travel_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.\n" \
                                             "It was Approved by Department Head on #{today_formatted}.\nTo view the request go to http://localhost:3000/travel_requests/#{travel_request.id}\n\n")
    end

    it "does not send a creator email" do
      expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "sends a supervisor email" do
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.</h1>\n" \
                                             "<p>It was Approved by Department Head on #{today_formatted}.</p>\n" \
                                             "<p>To view the canceled request go to <a href=\"http://localhost:3000/travel_requests/#{travel_request.id}\">here</a></p>\n#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.\n" \
                                             "It was Approved by Department Head on #{today_formatted}.\n" \
                                             "To view the canceled request go to http://localhost:3000/travel_requests/#{travel_request.id}\n")
    end
  end
end
