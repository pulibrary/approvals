require "rails_helper"

RSpec.describe "event_requests/edit", type: :view do
  before do
    @event_request = assign(:event_request, EventRequest.create!(
                              recurring_event: nil,
                              location: "MyString",
                              url: "MyString"
    ))
  end

  it "renders the edit event form" do
    render

    assert_select "form[action=?][method=?]", event_request_path(@event_request), "post" do
      assert_select "input[name=?]", "event_request[recurring_event_id]"

      assert_select "input[name=?]", "event_request[location]"

      assert_select "input[name=?]", "event_request[url]"
    end
  end
end
