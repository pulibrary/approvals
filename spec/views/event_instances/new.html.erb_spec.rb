require 'rails_helper'

RSpec.describe "event_instances/new", type: :view do
  before(:each) do
    assign(:event_instance, EventInstance.new(
      :event => nil,
      :location => "MyString",
      :url => "MyString"
    ))
  end

  it "renders new event_instance form" do
    render

    assert_select "form[action=?][method=?]", event_instances_path, "post" do

      assert_select "input[name=?]", "event_instance[event_id]"

      assert_select "input[name=?]", "event_instance[location]"

      assert_select "input[name=?]", "event_instance[url]"
    end
  end
end
