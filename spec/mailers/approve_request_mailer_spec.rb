# frozen_string_literal: true
require "rails_helper"

RSpec.describe ApproveMailer, type: :mailer do
  let(:supervisor) do
    aa = FactoryBot.create(:staff_profile, given_name: "Sally", surname: "Smith")
    head = FactoryBot.create(:staff_profile, given_name: "Department", surname: "Head")
    department = FactoryBot.create(:department, head: head, admin_assistants: [aa])
    FactoryBot.create :staff_profile, department: department, given_name: "Jane", surname: "Smith", supervisor: head
  end

  let(:user) { FactoryBot.create :user, uid: "jd4" }
  let(:creator) { FactoryBot.create :staff_profile, user: user, given_name: "Joe", surname: "Doe", supervisor: supervisor, department: supervisor.department }
  let(:travel_request) { FactoryBot.create :travel_request, creator: creator, start_date: Date.parse("2019/12/30"), end_date: Date.parse("2019/12/31"), travel_category: "professional_development" }
  let(:absence_request) { FactoryBot.create :absence_request, creator: creator, start_date: Date.parse("2019/12/30"), end_date: Date.parse("2019/12/31") }
  let(:today_formatted) { Time.zone.now.strftime(Rails.configuration.short_date_format) }

  context "unapproved absence" do
    it "does not send AA emails" do
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "sends review emails" do
      expect { described_class.with(request: absence_request).reviewer_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Ready For Review"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Ready for Review")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}/review\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  \n\n" \
                                             "To review the request for approval go to http://localhost:3000/absence_requests/#{absence_request.id}/review\n\n" \
                                             "Type: Vacation\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Total absence time in hours: 8.0\n\n")
    end

    it "does not send creator emails" do
      expect { described_class.with(request: absence_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "does not send supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  context "approved absence" do
    before do
      absence_request.approve(agent: supervisor)
    end

    it "sends AA emails" do
      expect { described_class.with(request: absence_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Approved"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Approved")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Approved by Jane Smith on #{today_formatted}.\n\n" \
                                             "To view the request go to http://localhost:3000/absence_requests/#{absence_request.id}\n\n" \
                                             "Type: Vacation\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Total absence time in hours: 8.0\n\n")
    end

    it "does not send reviewer emails" do
      expect { described_class.with(request: absence_request).reviewer_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "sends creator emails" do
      expect { described_class.with(request: absence_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Approved"
      expect(mail.to).to eq [creator.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Approved")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Type\n    Vacation\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Total absence time in hours\n    8.0\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/absence_requests/#{absence_request.id}\"]")
      expect(mail.text_part.body.to_s).to include("The following request was submitted on #{today_formatted}.  It has been Approved by Jane Smith on #{today_formatted}.\n" \
                                             "The approval has been forwarded to your supervisor and administrative assistant for their information.\n" \
                                             "Please proceed with recording your absence in the HR Self Service system (http://www.princeton.edu/hr/progserv/sds/applications/selfservice.html) " \
                                             "as soon as possible. Your supervisor will be confirming that you have reported this information at the end of the month.\n\n" \
                                             "To view your request go to http://localhost:3000/absence_requests/#{absence_request.id}\n\n" \
                                             "Type: Vacation\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Total absence time in hours: 8.0\n\n")
    end

    it "does not send supervisor emails" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  context "partially approve travel request" do
    before do
      travel_request.approve(agent: supervisor)
    end

    it "does not send AA emails" do
      expect { described_class.with(request: travel_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "sends creator email" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)
      expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Approved by Jane Smith Pending Further Review"
      expect(mail.to).to eq [creator.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Pending Further Review")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}. It has been Approved by Jane Smith on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Your request has been assigned to #{decorated_travel_request.travel_category} travel category.  " \
                                                       "To find more information about Travel Categories here")
      expect(mail.html_part.body.to_s).to have_content("Travel Category\n    #{decorated_travel_request.travel_category}\n    Trip ID\n    #{travel_request.id}\n    " \
                                                       "Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to include("The following request was submitted on #{today_formatted}.  It has been Approved by Jane Smith on #{today_formatted}.\n" \
                                             "The approval has been forwarded to your supervisor and administrative assistant for their information.\n" \
                                             "Your request has been assigned to #{decorated_travel_request.travel_category} travel category.  " \
                                             "To find more information about Travel Categories see https://pul-confluence.atlassian.net/wiki/spaces/LSC/pages/1933321/Princeton+University+Library+Travel+Policy+and+Best+Practices\n\n"\
                                             "To view your request go to http://localhost:3000/travel_requests/#{travel_request.id}\n\n" \
                                             "Travel Category: #{decorated_travel_request.travel_category}\nTrip ID: #{travel_request.id}\n" \
                                             "Type: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Destination: Location\n" \
                                             "Event: #{decorated_travel_request.event_title}\n\n")
    end

    it "sends reviewer email" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)
      expect { described_class.with(request: travel_request).reviewer_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Ready For Review"
      expect(mail.to).to eq [supervisor.department.head.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Ready for Review")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}. It has been Approved by Jane Smith on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Trip ID\n    #{travel_request.id}\n    Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}/review\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Approved by Jane Smith on #{today_formatted}.\n\n" \
                                             "To review the request for approval go to http://localhost:3000/travel_requests/#{travel_request.id}/review\n\n" \
                                             "Trip ID: #{travel_request.id}\nType: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Destination: Location\n" \
                                             "Event: #{decorated_travel_request.event_title}\n\n")
    end

    it "does not send supervisor emails" do
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  context "approved travel request" do
    before do
      travel_request.approve(agent: supervisor)
      travel_request.approve(agent: supervisor.department.head)
    end

    it "sends AA emails" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)

      expect { described_class.with(request: travel_request).admin_assistant_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Approved"
      expect(mail.to).to eq creator.admin_assistants.map(&:email)
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Approved")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}. It has been Approved by Department Head on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Travel Category\n    #{decorated_travel_request.travel_category}\n    Trip ID\n    #{travel_request.id}\n    Type\n    " \
                                                       "Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Approved by Department Head on #{today_formatted}.\n\n" \
                                             "To view the request go to http://localhost:3000/travel_requests/#{travel_request.id}\n\n" \
                                             "Travel Category: #{decorated_travel_request.travel_category}\nTrip ID: #{travel_request.id}\n" \
                                             "Type: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Destination: Location\n" \
                                             "Event: #{decorated_travel_request.event_title}\n\n")
    end

    it "sends creator email" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)

      expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Approved"
      expect(mail.to).to eq [creator.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Approved")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}. It has been Approved by Department Head on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Your request has been assigned to #{decorated_travel_request.travel_category} travel category.  " \
                                                       "To find more information about Travel Categories here")
      expect(mail.html_part.body.to_s).to have_content("Travel Category\n    #{decorated_travel_request.travel_category}\n    Trip ID\n    #{travel_request.id}\n    " \
                                                       "Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to include("The following request was submitted on #{today_formatted}.  It has been Approved by Department Head on #{today_formatted}.\n" \
                                             "The approval has been forwarded to your supervisor and administrative assistant for their information.\n" \
                                             "Your request has been assigned to #{decorated_travel_request.travel_category} travel category.  " \
                                             "To find more information about Travel Categories see https://pul-confluence.atlassian.net/wiki/spaces/LSC/pages/1933321/Princeton+University+Library+Travel+Policy+and+Best+Practices\n\n"\
                                             "To view your request go to http://localhost:3000/travel_requests/#{travel_request.id}\n\n" \
                                             "Travel Category: #{decorated_travel_request.travel_category}\nTrip ID: #{travel_request.id}\n" \
                                             "Type: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Destination: Location\n" \
                                             "Event: #{decorated_travel_request.event_title}\n\n")
    end

    it "does not send reviewer emails" do
      expect { described_class.with(request: travel_request).reviewer_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end

    it "sends supervisor emails" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Approved"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Approved")
      expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}. It has been Approved by Department Head on #{today_formatted}.")
      expect(mail.html_part.body.to_s).to have_content("Travel Category\n    #{decorated_travel_request.travel_category}\n    Trip ID\n    #{travel_request.id}\n    " \
                                                       "Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
      expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Approved by Department Head on #{today_formatted}.\n\n" \
                                             "To view the request go to http://localhost:3000/travel_requests/#{travel_request.id}\n\n" \
                                             "Travel Category: #{decorated_travel_request.travel_category}\nTrip ID: #{travel_request.id}\n" \
                                             "Type: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Destination: Location\n" \
                                             "Event: #{decorated_travel_request.event_title}\n\n")
    end
  end
end
