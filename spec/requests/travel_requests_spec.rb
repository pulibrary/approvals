# frozen_string_literal: true

require "rails_helper"

RSpec.describe TravelRequestsController, type: :request do
  let(:user) { create(:user) }
  let(:department_head) do
    profile = create(:staff_profile, user: user, given_name: "Sally", surname: "Smith")
    create(:department, head: profile)
    profile
  end
  let(:staff_profile) do
    create(:staff_profile, department: department_head.department, given_name: "John", surname: "Doe",
                           supervisor: department_head)
  end

  let(:travel_request) { create(:travel_request, creator: staff_profile) }
  let(:target_event) { create(:recurring_event, name: "Max's test event") }

  before do
    sign_in user
  end

  describe "changing the event_title" do
    let(:params) do
      {
        "travel_request" => {
          "notes" => { "content" => "" },
          "new_event" => { "id" => target_event_id }
        },
        "change_event" => "",
        "controller" => "travel_requests",
        "action" => "decide",
        "id" => "10049"
      }
    end

    context "with a valid new_event" do
      let(:target_event_id) { target_event.id }

      it "changes the event_title" do
        expect(travel_request.event_title).to match(/Event \d* \d*, Location/)

        put "/travel_requests/#{travel_request.id}/decide", params: params

        expect(travel_request.reload.event_title).to match(/Max's test event \d*, Location/)
        expect(flash[:success]).to eq("Travel request event name was successfully updated.")
      end
    end

    context "with an invalid new_event_name" do
      let(:target_event_id) { "" }

      it "does not change the event_title" do
        expect(travel_request.event_title).to match(/Event \d* \d*, Location/)

        put "/travel_requests/#{travel_request.id}/decide", params: params

        expect(travel_request.reload.event_title).to match(/Event \d* \d*, Location/)
        expect(flash[:alert]).to eq("New event name is required to specify requested changes.")
      end
    end
  end
end
