require "rails_helper"

RSpec.describe "events/edit", type: :view do
  before do
    @event = assign(:event, Event.create!(
                              name: "MyString",
                              description: "MyText",
                              url: "MyString"
    ))
  end

  it "renders the edit event form" do
    render

    assert_select "form[action=?][method=?]", event_path(@event), "post" do
      assert_select "input[name=?]", "event[name]"

      assert_select "textarea[name=?]", "event[description]"

      assert_select "input[name=?]", "event[url]"
    end
  end
end
