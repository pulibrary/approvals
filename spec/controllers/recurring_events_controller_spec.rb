# frozen_string_literal: true
require "rails_helper"

RSpec.describe RecurringEventsController, type: :controller do
  let(:valid_session) { {} }

  let(:user) { FactoryBot.create :user }
  let(:staff_profile) { FactoryBot.create :staff_profile, user: user }

  before do
    staff_profile
    sign_in user
  end

  describe "GET #index" do
    it "returns a success response" do
      event1 = FactoryBot.create :recurring_event, name: "Dev Congress"
      event2 = FactoryBot.create :recurring_event, name: "Ops Congress"
      event3 = FactoryBot.create :recurring_event, name: "Meeting for All"
      get :index, params: {}, session: valid_session
      expect(response).to be_successful
      expect(assigns[:recurring_events]).to eq [event1, event3, event2]
    end

    it "filters by search" do
      event1 = FactoryBot.create :recurring_event, name: "Dev Congress"
      event2 = FactoryBot.create :recurring_event, name: "Ops Congress"
      event3 = FactoryBot.create :recurring_event, name: "Meeting for All"
      get :index, params: { query: "Congress" }, session: valid_session
      expect(response).to be_successful
      expect(assigns[:recurring_events]).to eq [event1, event2]
    end
  end

  describe "PUT #combine" do
    it "returns a success response" do
      event1 = FactoryBot.create :recurring_event, name: "Dev Congress"
      event2 = FactoryBot.create :recurring_event, name: "Developer congress"
      request1 = FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event1)]
      request2 = FactoryBot.create :travel_request, event_requests: [FactoryBot.build(:event_request, recurring_event: event2)]
      put :combine, params: { combined_name: "Developer Congress", selected_events: [event1.id, event2.id] }, session: valid_session
      expect(response).to be_redirect
      expect(EventRequest.where(recurring_event: event1).count).to eq(2)
      expect(RecurringEvent.find_by(id: event2)).to be_nil
    end
  end
end
