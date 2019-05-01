require "rails_helper"

RSpec.describe "staff_profiles/edit", type: :view do
  let(:staff_profile) { FactoryBot.create(:staff_profile) }
  before do
    assign(:staff_profile, staff_profile)
  end

  it "renders the edit staff_profile form" do
    render

    assert_select "form[action=?][method=?]", staff_profile_path(staff_profile), "post" do
      assert_select "input[name=?]", "staff_profile[user_id]"

      assert_select "input[name=?]", "staff_profile[department_id]"

      assert_select "input[name=?]", "staff_profile[supervisor]"

      assert_select "input[name=?]", "staff_profile[biweekly]"
    end
  end
end
