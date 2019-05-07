require "rails_helper"

RSpec.describe "recurring_events/edit", type: :view do
  before do
    @recurring_event = assign(:recurring_event, FactoryBot.create(
                                                  :recurring_event,
                                                  name: "MyString",
                                                  description: "MyText",
                                                  url: "MyString"
    ))
  end

  it "renders the edit recurring_event form" do
    render

    assert_select "form[action=?][method=?]", recurring_event_path(@recurring_event), "post" do
      assert_select "input[name=?]", "recurring_event[name]"

      assert_select "textarea[name=?]", "recurring_event[description]"

      assert_select "input[name=?]", "recurring_event[url]"
    end
  end
end
