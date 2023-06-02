# frozen_string_literal: true
require "rails_helper"

RSpec.describe "travel_requests/_review_detail", type: :view do
  describe "event format badge" do
    let(:creator) { FactoryBot.create(:staff_profile, :with_supervisor, given_name: "Sally", surname: "Smith") }
    let(:travel_request) { TravelRequestDecorator.new(FactoryBot.create(:travel_request, :with_note_and_estimate, creator: creator)) }
    it "has a green Virtual badge" do
      without_partial_double_verification do
        allow(view).to receive(:travel_request).and_return(travel_request)
        render
      end
      expect(rendered).to have_selector('tag[@color = "green"]', text: "Virtual")
    end
  end
end
