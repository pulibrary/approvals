require "rails_helper"

RSpec.describe "recurring_events/new", type: :view do
  before do
    assign(:recurring_event, RecurringEvent.new(
                               name: "MyString",
                               description: "MyText",
                               url: "MyString"
    ))
  end

  it "renders new recurring_event form" do
    render

    assert_select "form[action=?][method=?]", recurring_events_path, "post" do
      assert_select "input[name=?]", "recurring_event[name]"

      assert_select "textarea[name=?]", "recurring_event[description]"

      assert_select "input[name=?]", "recurring_event[url]"
    end
  end
end
