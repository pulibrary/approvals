require "rails_helper"

RSpec.describe "events/new", type: :view do
  before do
    assign(:event, Event.new(
                     recurring_event: nil,
                     location: "MyString",
                     url: "MyString"
    ))
  end

  it "renders new event form" do
    render

    assert_select "form[action=?][method=?]", events_path, "post" do
      assert_select "input[name=?]", "event[recurring_event_id]"

      assert_select "input[name=?]", "event[location]"

      assert_select "input[name=?]", "event[url]"
    end
  end
end
