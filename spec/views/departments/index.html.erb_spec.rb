# frozen_string_literal: true
require "rails_helper"

RSpec.describe "departments/index", type: :view do
  let(:staff_profile) { FactoryBot.create(:staff_profile) }
  before do
    assign(:departments, [
             FactoryBot.create(
               :department,
               name: "Name",
               head_id: 2,
               admin_assistant_ids: [staff_profile.id]
             ),
             FactoryBot.create(
               :department,
               name: "Name",
               head_id: 2,
               admin_assistant_ids: [staff_profile.id]
             )
           ])
  end

  it "renders a list of departments" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: 2.to_s, count: 2
    assert_select "tr>td", text: [staff_profile.id].to_s, count: 2
  end
end
