require "rails_helper"

RSpec.describe "event_instances/index", type: :view do
  let(:event) { Event.create! }
  before do
    assign(:event_instances, [
             EventInstance.create!(
               event: event,
               location: "Location",
               url: "Url"
             ),
             EventInstance.create!(
               event: event,
               location: "Location",
               url: "Url"
             )
           ])
  end

  it "renders a list of event_instances" do
    render
    assert_select "tr>td", text: event.to_s, count: 2
    assert_select "tr>td", text: "Location".to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
  end
end
