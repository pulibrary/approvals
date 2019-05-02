require "rails_helper"

RSpec.describe "event_requests/index", type: :view do
  let(:recurring_event) { RecurringEvent.create! }
  let(:staff_profile) { FactoryBot.create(:staff_profile) }
  before do
    assign(:event_requests, [
             EventRequest.create!(
               recurring_event: recurring_event,
               location: "Location",
               url: "Url",
               request: Request.create!(creator: staff_profile)
             ),
             EventRequest.create!(
               recurring_event: recurring_event,
               location: "Location",
               url: "Url",
               request: Request.create!(creator: staff_profile)
             )
           ])
  end

  it "renders a list of event_requests" do
    render
    assert_select "tr>td", text: recurring_event.to_s, count: 2
    assert_select "tr>td", text: "Location".to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
  end
end
