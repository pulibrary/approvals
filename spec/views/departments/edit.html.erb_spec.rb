require "rails_helper"

RSpec.describe "departments/edit", type: :view do
  let(:department) do
    Department.create!(
      name: "MyString",
      head_id: 1,
      admin_assistant_id: 1
    )
  end

  before do
    assign(:department, department)
    render
  end

  it "renders the edit department form" do
    assert_select "form[action=?][method=?]", department_path(department), "post" do
      assert_select "input[name=?]", "department[name]"

      assert_select "input[name=?]", "department[head_id]"

      assert_select "input[name=?]", "department[admin_assistant_id]"
    end
  end
end
