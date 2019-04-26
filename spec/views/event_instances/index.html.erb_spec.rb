require "rails_helper"

RSpec.describe "event_instances/index", type: :view do
  let(:recurring_event) { RecurringEvent.create! }
  before do
    assign(:event_instances, [
             EventInstance.create!(
               recurring_event: recurring_event,
               location: "Location",
               url: "Url"
             ),
             EventInstance.create!(
               recurring_event: recurring_event,
               location: "Location",
               url: "Url"
             )
           ])
  end

  it "renders a list of event_instances" do
    render
    assert_select "tr>td", text: recurring_event.to_s, count: 2
    assert_select "tr>td", text: "Location".to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
  end
end
