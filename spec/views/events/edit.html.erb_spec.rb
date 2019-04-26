require "rails_helper"

RSpec.describe "events/edit", type: :view do
  before do
    @event = assign(:event, Event.create!(
                              recurring_event: nil,
                              location: "MyString",
                              url: "MyString"
    ))
  end

  it "renders the edit event form" do
    render

    assert_select "form[action=?][method=?]", event_path(@event), "post" do
      assert_select "input[name=?]", "event[recurring_event_id]"

      assert_select "input[name=?]", "event[location]"

      assert_select "input[name=?]", "event[url]"
    end
  end
end
