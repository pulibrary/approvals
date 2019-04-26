require "rails_helper"

RSpec.describe "recurring_events/index", type: :view do
  before do
    assign(:recurring_events, [
             RecurringEvent.create!(
               name: "Name",
               description: "MyText",
               url: "Url"
             ),
             RecurringEvent.create!(
               name: "Name",
               description: "MyText",
               url: "Url"
             )
           ])
  end

  it "renders a list of recurring_events" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
    assert_select "tr>td", text: "Url".to_s, count: 2
  end
end
