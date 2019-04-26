require "rails_helper"

RSpec.describe "events/index", type: :view do
  let(:recurring_event) { RecurringEvent.create! }
  before do
    assign(:events, [
             Event.create!(
               recurring_event: recurring_event,
               location: "Location",
               url: "Url"
             ),
             Event.create!(
               recurring_event: recurring_event,
               location: "Location",
               url: "Url"
             )
           ])
  end

  it "renders a list of events" do
    render
    assert_select "tr>td", text: recurring_event.to_s, count: 2
    assert_select "tr>td", text: "Location".to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
  end
end
