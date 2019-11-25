# frozen_string_literal: true
require "rails_helper"

RSpec.describe "departments/edit", type: :view do
  let (:staff_profile)  { FactoryBot.create(:staff_profile) }
  let(:department) do
    FactoryBot.create(
      :department,
      name: "MyString",
      head_id: 1,
      admin_assistant_ids: [staff_profile.id]
    )
  end

  before do
    assign(:department, department)
    render
  end

  it "renders the edit department form" do
    assert_select "form[action=?][method=?]", department_path(department), "post" do
      assert_select "input[name=?][value=?]", "department[name]", department.name

      assert_select "input[name=?][value=?]", "department[head_id]", department.head_id.to_s

      assert_select "input[name=?][value=?]", "department[admin_assistant_ids]", department.admin_assistant_ids.first.to_s
    end
  end
end
