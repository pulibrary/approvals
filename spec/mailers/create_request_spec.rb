# frozen_string_literal: true
require "rails_helper"

RSpec.describe CreateMailer, type: :mailer do
  let(:supervisor) do
    aa = FactoryBot.create(:staff_profile, given_name: "Sally", surname: "Smith")
    head = FactoryBot.create(:staff_profile, given_name: "Department", surname: "Head")
    department = FactoryBot.create(:department, head: head, admin_assistants: [aa])
    FactoryBot.create :staff_profile, department: department, given_name: "Jane", surname: "Smith", supervisor: head
  end

  let(:user) { FactoryBot.create :user, uid: "jd4" }
  let(:creator) { FactoryBot.create :staff_profile, user: user, given_name: "Joe", surname: "Doe", supervisor: supervisor, department: supervisor.department }
  let(:travel_request) { FactoryBot.create :travel_request, creator: creator, start_date: Date.parse("2019/12/30"), end_date: Date.parse("2019/12/31") }
  let(:today_formatted) { Time.zone.now.strftime(Rails.configuration.short_date_format) }

  it "sends reviewer email" do
    decorated_travel_request = TravelRequestDecorator.new(travel_request)
    expect { described_class.with(request: travel_request).reviewer_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq "#{decorated_travel_request.title} Ready For Review"
    expect(mail.to).to eq [supervisor.email]
    expect(mail.html_part.body.to_s).to have_content("Leave and Travel Request - Ready for Review")
    expect(mail.html_part.body.to_s).to have_content("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}")
    expect(mail.html_part.body.to_s).to have_content("Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n")
    expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}/review\"]")
    expect(mail.text_part.body.to_s).to eq("The following request was submitted by Doe, Joe (jd4) on #{today_formatted}.\n\n" \
                                           "To review the request for approval go to http://localhost:3000/travel_requests/#{travel_request.id}/review\n\n" \
                                           "Type: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                           "Destination: Location\n" \
                                           "Event: #{decorated_travel_request.event_title}\n\n")
  end

  it "does not send a creator email" do
    expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(0)
  end

  it "does send a creator email if there is a note to specifying someone else created the request" do
    Note.create request: travel_request, creator: supervisor, content: "I created this"
    decorated_travel_request = TravelRequestDecorator.new(travel_request.reload)
    expect { described_class.with(request: travel_request).creator_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq "#{decorated_travel_request.title} Created by Jane Smith"
    expect(mail.to).to eq [creator.email]
    expect(mail.html_part.body.to_s).to have_content("Leave and Travel Request - Submitted for You")
    expect(mail.html_part.body.to_s).to have_content("The following request was submitted on #{today_formatted}")
    expect(mail.html_part.body.to_s).to have_content("Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n")
    expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}\"]")
    expect(mail.text_part.body.to_s).to eq("The following request was submitted for you on #{today_formatted}.\n" \
                                           "To view your request go to http://localhost:3000/travel_requests/#{travel_request.id}\n" \
                                           "Type: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                           "Destination: Location\n" \
                                           "Event: #{decorated_travel_request.event_title}\n\n")
  end
end
