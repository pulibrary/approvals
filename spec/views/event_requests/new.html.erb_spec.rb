require "rails_helper"

RSpec.describe "event_requests/new", type: :view do
  before do
    assign(:event_request, EventRequest.new(
                             recurring_event: nil,
                             location: "MyString",
                             url: "MyString"
    ))
  end

  it "renders new event request form" do
    render

    assert_select "form[action=?][method=?]", event_requests_path, "post" do
      assert_select "input[name=?]", "event_request[recurring_event_id]"

      assert_select "input[name=?]", "event_request[location]"

      assert_select "input[name=?]", "event_request[url]"
    end
  end
end
