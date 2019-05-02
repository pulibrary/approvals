require "rails_helper"

RSpec.describe "staff_profiles/new", type: :view do
  before do
    assign(:staff_profile, FactoryBot.build(:staff_profile))
  end

  it "renders new staff_profile form" do
    render

    assert_select "form[action=?][method=?]", staff_profiles_path, "post" do
      assert_select "input[name=?]", "staff_profile[user_id]"

      assert_select "input[name=?]", "staff_profile[department_id]"

      assert_select "input[name=?]", "staff_profile[supervisor]"

      assert_select "input[name=?]", "staff_profile[biweekly]"
    end
  end
end
