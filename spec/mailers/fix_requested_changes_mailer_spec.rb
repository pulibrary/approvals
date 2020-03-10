# frozen_string_literal: true
require "rails_helper"

RSpec.describe FixRequestedChangesMailer, type: :mailer do
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
    travel_request.change_request(agent: creator.supervisor)
    travel_request.fix_requested_changes(agent: creator)
    decorated_travel_request = TravelRequestDecorator.new(travel_request)
    expect { described_class.with(request: travel_request).reviewer_email.deliver }.to change { ActionMailer::Base.deliveries.count }.by(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq "#{decorated_travel_request.title} Updated and Ready For Review"
    expect(mail.to).to eq [supervisor.email]
    expect(mail.html_part.body.to_s).to have_content("Absence and Travel Request - Updated")
    expect(mail.html_part.body.to_s).to have_content("The following request was updated by Doe, Joe (jd4) on #{today_formatted}.")
    expect(mail.html_part.body.to_s).to have_content("Trip ID\n    #{travel_request.id}\n    Type\n    Travel Request\n    Dates Away\n    12/30/2019 to 12/31/2019\n    Destination\n    Location\n")
    expect(mail.html_part.body).to have_selector("a[href=\"http://localhost:3000/travel_requests/#{travel_request.id}/review\"]")
    expect(mail.text_part.body.to_s).to eq("The following request was updated by Doe, Joe (jd4) on #{today_formatted}.\n\n" \
                                           "To review the request for approval go to http://localhost:3000/travel_requests/#{travel_request.id}/review\n\n" \
                                           "Trip ID: #{travel_request.id}\nType: Travel Request\nDates Away: 12/30/2019 to 12/31/2019\n" \
                                           "Destination: Location\n" \
                                           "Event: #{decorated_travel_request.event_title}\n\n")
  end
end
