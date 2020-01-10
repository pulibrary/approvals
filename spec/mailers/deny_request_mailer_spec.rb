# frozen_string_literal: true
require "rails_helper"

RSpec.describe DenyMailer, type: :mailer do
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

  context "denied absence" do
    before do
      absence_request.deny!(agent: supervisor)
    end

    it "sends creator email" do
      expect { described_class.with(request: absence_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{AbsenceRequestDecorator.new(absence_request).title} Denied"
      expect(mail.to).to eq [creator.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted on #{today_formatted}.  It has been Denied by Jane Smith on #{today_formatted}.</h1>\n" \
                                             "<p>To view your request go to <a href=\"http://localhost:3000/absence_requests/#{absence_request.id}\">here</a></p>\n  <dl>\n    " \
                                             "<dt>Type</dt><dd>AbsenceRequest</dd>\n    <dt>Dates Away</dt><dd>12/30/2019 to 12/31/2019</dd>\n    " \
                                             "<dt>Total absence time in hours</dt><dd>8.0</dd>\n  </dl>#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted on #{today_formatted}.  It has been Denied by Jane Smith on #{today_formatted}.\n" \
                                             "To view your request go to http://localhost:3000/absence_requests/#{absence_request.id}\n" \
                                             "Type: AbsenceRequest\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Total absence time in hours: 8.0\n\n")
    end

    it "does not send supervisor email" do
      expect { described_class.with(request: absence_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  context "denied travel request" do
    before do
      travel_request.deny!(agent: supervisor)
    end

    it "sends creator email" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)
      expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Denied"
      expect(mail.to).to eq [creator.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted on #{today_formatted}.  It has been Denied by Jane Smith on #{today_formatted}.</h1>\n" \
                                             "<p>To view your request go to <a href=\"http://localhost:3000/travel_requests/#{travel_request.id}\">here</a></p>\n  <dl>\n    " \
                                             "<dt>Type</dt><dd>TravelRequest</dd>\n    <dt>Dates Away</dt><dd>12/30/2019 to 12/31/2019</dd>\n    " \
                                             "<dt>Destination</dt><dd>Location</dd>\n    <dt>Event</dt><dd>#{decorated_travel_request.event_title}</dd>\n  </dl>#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted on #{today_formatted}.  It has been Denied by Jane Smith on #{today_formatted}.\n" \
                                             "To view your request go to http://localhost:3000/travel_requests/#{travel_request.id}\n" \
                                             "Type: TravelRequest\nDates Away: 12/30/2019 to 12/31/2019\n" \
        "Destination: Location\n" \
        "Event: #{decorated_travel_request.event_title}\n\n")
    end

    it "does not send supervisor email" do
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
    end
  end

  context "denied travel request by department head" do
    before do
      travel_request.approve(agent: supervisor)
      travel_request.deny!(agent: supervisor.supervisor)
    end

    it "sends creator email" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)
      expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Denied"
      expect(mail.to).to eq [creator.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted on #{today_formatted}.  " \
                                             "It has been Denied by Department Head on #{today_formatted}.</h1>\n" \
                                             "<p>To view your request go to <a href=\"http://localhost:3000/travel_requests/#{travel_request.id}\">here</a></p>\n  <dl>\n    " \
                                             "<dt>Type</dt><dd>TravelRequest</dd>\n    <dt>Dates Away</dt><dd>12/30/2019 to 12/31/2019</dd>\n    " \
                                             "<dt>Destination</dt><dd>Location</dd>\n    <dt>Event</dt><dd>#{decorated_travel_request.event_title}</dd>\n  </dl>#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted on #{today_formatted}.  It has been Denied by Department Head on #{today_formatted}.\n" \
                                             "To view your request go to http://localhost:3000/travel_requests/#{travel_request.id}\n" \
                                             "Type: TravelRequest\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Destination: Location\n" \
                                             "Event: #{decorated_travel_request.event_title}\n\n")
    end

    it "sends supervisor email" do
      decorated_travel_request = TravelRequestDecorator.new(travel_request)
      expect { described_class.with(request: travel_request).supervisor_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "#{decorated_travel_request.title} Denied"
      expect(mail.to).to eq [supervisor.email]
      expect(mail.html_part.body.to_s).to eq("#{html_email_heading}<h1>The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  " \
                                             "It has been Denied by Department Head on #{today_formatted}.</h1>\n" \
                                             "<p>To view the request go to <a href=\"http://localhost:3000/travel_requests/#{travel_request.id}\">here</a></p>\n  <dl>\n    " \
                                             "<dt>Type</dt><dd>TravelRequest</dd>\n    <dt>Dates Away</dt><dd>12/30/2019 to 12/31/2019</dd>\n    " \
                                             "<dt>Destination</dt><dd>Location</dd>\n    <dt>Event</dt><dd>#{decorated_travel_request.event_title}</dd>\n  </dl>#{html_email_footer}")
      expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.  It has been Denied by Department Head on #{today_formatted}.\n" \
                                             "To view the request go to http://localhost:3000/travel_requests/#{travel_request.id}\n" \
                                             "Type: TravelRequest\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                             "Destination: Location\n" \
                                             "Event: #{decorated_travel_request.event_title}\n\n")
    end
  end
end