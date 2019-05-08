require "rails_helper"

RSpec.describe "staff_profiles/edit", type: :view do
  let(:staff_profile) { FactoryBot.create(:staff_profile, :with_supervisor) }
  before do
    assign(:staff_profile, staff_profile)
  end

  it "renders the edit staff_profile form" do
    render

    assert_select "form[action=?][method=?]", staff_profile_path(staff_profile), "post" do
      assert_select "input[name=?][value=?]", "staff_profile[user_id]", staff_profile.user_id.to_s

      assert_select "input[name=?][value=?]", "staff_profile[department_id]", staff_profile.department_id.to_s

      assert_select "input[name=?][value=?]", "staff_profile[supervisor_id]", staff_profile.supervisor_id.to_s

      assert_select "input[name=?][value=?]", "staff_profile[biweekly]", staff_profile.biweekly ? "1" : "0"
    end
  end
end
