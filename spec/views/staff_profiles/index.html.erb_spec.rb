# frozen_string_literal: true
require "rails_helper"

RSpec.describe "staff_profiles/index", type: :view do
  let(:staff_profile1) { FactoryBot.create(:staff_profile, :with_supervisor) }
  let(:staff_profile2) { FactoryBot.create(:staff_profile, :with_supervisor) }
  before do
    assign(:staff_profiles, [staff_profile1, staff_profile2])
  end

  it "renders a list of staff_profiles" do
    render

    assert_select "tr>td", text: staff_profile1.user.to_s
    assert_select "tr>td", text: staff_profile2.user.to_s
    assert_select "tr>td", text: staff_profile1.department.to_s
    assert_select "tr>td", text: staff_profile2.department.to_s
    assert_select "tr>td", text: staff_profile1.supervisor.to_s
    assert_select "tr>td", text: staff_profile2.supervisor.to_s
    assert_select "tr>td", text: false.to_s, count: 2
  end
end
