# frozen_string_literal: true
require "rails_helper"

RSpec.describe "staff_profiles/new", type: :view do
  let(:staff_profile) { FactoryBot.build(:staff_profile) }
  before do
    assign(:staff_profile, staff_profile)
  end

  it "renders new staff_profile form" do
    render

    assert_select "form[action=?][method=?]", staff_profiles_path, "post" do
      assert_select "input[name=?][value=?]", "staff_profile[user_id]", staff_profile.user_id.to_s

      assert_select "input[name=?][value=?]", "staff_profile[department_id]", staff_profile.department_id.to_s

      assert_select "input[name=?]", "staff_profile[supervisor_id]"

      assert_select "input[name=?][value=?]", "staff_profile[biweekly]", staff_profile.biweekly ? "1" : "0"
    end
  end
end
