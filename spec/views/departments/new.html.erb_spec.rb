require "rails_helper"

RSpec.describe "departments/new", type: :view do
  let(:department) { Department.new(name: "MyString", head_id: 1, admin_assistant_id: 1) }
  before do
    assign(:department, department)
  end

  it "renders new department form" do
    render

    assert_select "form[action=?][method=?]", departments_path, "post" do
      assert_select "input[name=?][value=?]", "department[name]", department.name

      assert_select "input[name=?][value=?]", "department[head_id]", department.head_id.to_s

      assert_select "input[name=?][value=?]", "department[admin_assistant_id]", department.admin_assistant_id.to_s
    end
  end
end
