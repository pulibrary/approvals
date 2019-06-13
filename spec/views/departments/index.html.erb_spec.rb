# frozen_string_literal: true
require "rails_helper"

RSpec.describe "departments/index", type: :view do
  before do
    assign(:departments, [
             FactoryBot.create(
               :department,
               name: "Name",
               head_id: 2,
               admin_assistant_id: 3
             ),
             FactoryBot.create(
               :department,
               name: "Name",
               head_id: 2,
               admin_assistant_id: 3
             )
           ])
  end

  it "renders a list of departments" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: 3.to_s, count: 2
  end
end
