# frozen_string_literal: true

require "rails_helper"

RSpec.describe "travel_requests/_review_detail", type: :view, js: true do
  describe "event format badge" do
    let(:creator) { FactoryBot.create(:staff_profile, :with_supervisor, given_name: "Sally", surname: "Smith") }

    context "when event is virtual" do
      let(:travel_request) do
 TravelRequestDecorator.new(FactoryBot.create(:travel_request, :with_note_and_estimate, creator:,
                                                                                        virtual_event: true))
      end

      it "has a green Virtual badge" do
        without_partial_double_verification do
          allow(view).to receive(:travel_request).and_return(travel_request)
          render
        end
        virtual_badge = Capybara::Node::Simple.new(rendered).all("lux-tag")[1]
        expect(virtual_badge[":tag-items"]).to include("{name: 'Virtual', color: 'green'}")
      end
    end

    context "when event is in-person" do
      let(:travel_request) do
 TravelRequestDecorator.new(FactoryBot.create(:travel_request, :with_note_and_estimate, creator:))
      end

      it "has a blue In-person badge" do
        without_partial_double_verification do
          allow(view).to receive(:travel_request).and_return(travel_request)
          render
        end
        in_person_badge = Capybara::Node::Simple.new(rendered).all("lux-tag")[1]
        expect(in_person_badge[":tag-items"]).to include("{name: 'In-person', color: 'blue'}")
      end
    end

    context "when event format is unknown" do
      let(:travel_request) do
 TravelRequestDecorator.new(FactoryBot.create(:travel_request, :with_note_and_estimate, creator:, virtual_event: nil))
      end

      it "shows no badge" do
        without_partial_double_verification do
          allow(view).to receive(:travel_request).and_return(travel_request)
          render
        end
        expect(Capybara::Node::Simple.new(rendered).all("lux-tag").count).to eq(1)
      end
    end
  end
end
