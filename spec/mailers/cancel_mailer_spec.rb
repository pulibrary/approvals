# frozen_string_literal: true

require "rails_helper"

RSpec.describe CancelMailer, type: :mailer do
  let(:supervisor) do
    aa = FactoryBot.create(:staff_profile, given_name: "Sally", surname: "Smith")
    head = FactoryBot.create(:staff_profile, given_name: "Department", surname: "Head")
    department = FactoryBot.create(:department, head:, admin_assistants: [aa])
    FactoryBot.create :staff_profile, department:, given_name: "Jane", surname: "Smith", supervisor: head
  end

  let(:user) { FactoryBot.create :user, uid: "jd4" }
  let(:creator) do
 FactoryBot.create :staff_profile, user:, given_name: "Joe", surname: "Doe", supervisor:,
                                   department: supervisor.department
  end
  let(:travel_request) do
 FactoryBot.create :travel_request, creator:, start_date: Date.parse("2019/12/30"), end_date: Date.parse("2019/12/31")
  end
  let(:absence_request) do
 FactoryBot.create :absence_request, creator:, start_date: Date.parse("2019/12/30"),
                                     end_date: Date.parse("2019/12/31")
  end
  let(:today_formatted) { Time.zone.now.strftime(Rails.configuration.short_date_format) }

  context "unapproved absence" do
    before do
      absence_request.cancel(agent: creator)
    end

    it "does not send AA emails" do
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.not_to change {
 ActionMailer::Base.deliveries.count
                                                                                                     }
    end

    it "Sends supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                            }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}. \n\n" \
                                             "To view the canceled request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end
  end

  context "approved absence" do
    before do
      absence_request.approve(agent: supervisor)
      absence_request.cancel(agent: creator)
    end

    it "sends AA emails" do
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                                 }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}. " \
                                                       "It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Jane Smith on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.  It was Approved by Jane Smith on #{today_formatted}.\n\n" \
                                             "To view the request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end

    it "sends supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                            }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                                       "It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Jane Smith on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Jane Smith on #{today_formatted}.\n\n" \
                                             "To view the canceled request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end
  end

  context "recorded absence" do
    before do
      absence_request.approve(agent: supervisor)
      absence_request.record(agent: creator)
      absence_request.cancel(agent: creator)
    end

    it "sends AA emails" do
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                                 }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}. " \
                                                       "It has been Canceled by Joe Doe on #{today_formatted}. It was Recorded by Joe Doe on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.  It was Recorded by Joe Doe on #{today_formatted}.\n\n" \
                                             "Please verify the request has been canceled in the HR Self Service System: http://www.princeton.edu/hr/progserv/sds/applications/selfservice.html\n\n" \
                                             "To view the request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end

    it "sends supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                            }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                                       "It has been Canceled by Joe Doe on #{today_formatted}. It was Recorded by Joe Doe on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}. It was Recorded by Joe Doe on #{today_formatted}.\n\n" \
                                             "To view the canceled request go to http://localhost:3000/absence_requests/#{absence_request.id}\n")
    end
  end

  context "partially approve travel request" do
    before do
      travel_request.approve(agent: supervisor)
      travel_request.cancel(agent: creator)
    end

    it "sends AA emails" do
      expect { described_class.with(request: travel_request).admin_assistant_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                                }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Jane Smith on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}.  It was Approved by Jane Smith on #{today_formatted}.\n\n" \
                                             "To view the request go to http://localhost:3000/travel_requests/#{travel_request.id}\n")
    end

    it "sends a supervisor email" do
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                           }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Jane Smith on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Jane Smith on #{today_formatted}.\n\n" \
                                             "To view the canceled request go to http://localhost:3000/travel_requests/#{travel_request.id}\n")
    end
  end

  context "approved travel request" do
    before do
      travel_request.approve(agent: supervisor)
      travel_request.approve(agent: supervisor.department.head)
      travel_request.cancel(agent: creator)
    end

    it "sends AA emails" do
      expect { described_class.with(request: travel_request).admin_assistant_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                                }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Department Head on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}.  "\
                                             "It was Approved by Department Head on #{today_formatted}.\n\n" \
                                             "To view the request go to http://localhost:3000/travel_requests/#{travel_request.id}\n")
    end

    it "sends a supervisor email" do
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change {
 ActionMailer::Base.deliveries.count
                                                                                           }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{TravelRequestDecorator.new(travel_request).title} Canceled"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Canceled")
      expect(mail.html_part.body.to_s).to have_content("It has been Canceled by Joe Doe on #{today_formatted}. It was Approved by Department Head on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Canceled by Joe Doe on #{today_formatted}. " \
                                             "It was Approved by Department Head on #{today_formatted}.\n\n" \
                                             "To view the canceled request go to http://localhost:3000/travel_requests/#{travel_request.id}\n")
    end
  end
end
